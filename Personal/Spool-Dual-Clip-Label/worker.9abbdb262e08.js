import OpenSCAD from "./openscad-wasm/openscad.js"
import * as THREE from "https://esm.sh/three@0.160.0"
import { STLLoader } from "https://esm.sh/three@0.160.0/examples/jsm/loaders/STLLoader.js"
import { GLTFExporter } from "https://esm.sh/three@0.160.0/examples/jsm/exporters/GLTFExporter.js"

console.log("Worker started")

const MAX_LOG_CHARS = 1024 * 1024
let currentLog = ""
let currentLogTruncated = false

function stringifyLogValue(v) {
    if (v instanceof Error) {
        return v && v.stack ? String(v.stack) : String(v)
    }
    if (typeof v === "string") {
        return v
    }
    if (v === null) {
        return "null"
    }
    if (v === undefined) {
        return "undefined"
    }
    try {
        return JSON.stringify(v)
    } catch (e) {
        return String(v)
    }
}

function appendLogLine(line) {
    if (!line) {
        line = ""
    }
    currentLog += String(line) + "\n"
    if (currentLog.length > MAX_LOG_CHARS) {
        currentLog = currentLog.slice(currentLog.length - MAX_LOG_CHARS)
        if (!currentLogTruncated) {
            currentLogTruncated = true
            currentLog = "[log truncated]\n" + currentLog
        }
    }
}

function logToConsoleAndBuffer(level, ...args) {
    const line = args.map(stringifyLogValue).join(" ")
    appendLogLine(line)
    const fn = console[level] || console.log
    fn.apply(console, args)
}

function logInfo(...args) {
    logToConsoleAndBuffer("log", ...args)
}

function logError(...args) {
    logToConsoleAndBuffer("error", ...args)
}

function formatErrorForMessage(e) {
    if (e instanceof Error) {
        return String(e && e.message ? e.message : e)
    }
    if (typeof e === "string") {
        return e
    }
    if (!e || typeof e !== "object") {
        return String(e)
    }

    const message = typeof e.message === "string" ? e.message.trim() : ""
    if (message) {
        return message
    }
    if (typeof e.name === "string" && e.name) {
        if (typeof e.errno === "number") {
            return `${e.name} (errno ${e.errno})`
        }
        return e.name
    }
    if (typeof e.errno === "number") {
        return `Error (errno ${e.errno})`
    }
    try {
        return JSON.stringify(e)
    } catch (err) {
        return String(e)
    }
}

let runQueue = Promise.resolve()
// OpenSCAD's WASM build aborts its runtime after a render.
// Create a fresh instance for each render.

const INPUTS = ["/Spool-Dual-Clip-Label.scad"]

function base64ToUint8Array(base64) {
    const binary = atob(base64)
    const bytes = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i)
    }
    return bytes
}

function uint8ArrayToArrayBuffer(bytes) {
    return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength)
}

async function stlBytesToGlb(stlBytes) {
    let geometry = new STLLoader().parse(uint8ArrayToArrayBuffer(stlBytes))
    if (geometry.index) {
        // STL is typically non-indexed, but if we ever get indexed geometry,
        // convert to non-indexed so per-triangle vertex colors are stable.
        geometry = geometry.toNonIndexed()
    }
    if (!geometry.getAttribute("normal")) {
        geometry.computeVertexNormals()
    }

    // Add simple depth cueing: tint triangles based on their Z position.
    // This makes pockets easier to read without AO.
    {
        const pos = geometry.getAttribute("position")
        if (pos && pos.count >= 3) {
            let minZ = Infinity
            let maxZ = -Infinity
            for (let i = 0; i < pos.count; i++) {
                const z = pos.getZ(i)
                if (z < minZ) minZ = z
                if (z > maxZ) maxZ = z
            }

            const range = maxZ - minZ
            if (isFinite(range) && range > 0) {
                // this logic shades faces based on Z position to make pockets easier to distinguish

                // Base material color is 0x9aa3ad; these are subtle tints around it.
                const topColor = new THREE.Color(0x63696f)
                const bottomColor = new THREE.Color(0xc4d0dd)

                const colors = new Float32Array(pos.count * 3)
                // geometry is non-indexed, so each triangle is 3 consecutive vertices.
                for (let i = 0; i < pos.count; i += 3) {
                    const z0 = pos.getZ(i)
                    const z1 = pos.getZ(i + 1)
                    const z2 = pos.getZ(i + 2)
                    const z = Math.min(z0, z1, z2)
                    const t = (z - minZ) / range

                    const c = bottomColor.clone().lerp(topColor, t)
                    for (let j = 0; j < 3; j++) {
                        const k = (i + j) * 3
                        colors[k] = c.r
                        colors[k + 1] = c.g
                        colors[k + 2] = c.b
                    }
                }
                geometry.setAttribute("color", new THREE.BufferAttribute(colors, 3))
            }
        }
    }

    const material = new THREE.MeshStandardMaterial({
        color: 0xc4d0dd,
        metalness: 0.8,
        roughness: 0.4,
        flatShading: true,
        vertexColors: true,
    })
    const mesh = new THREE.Mesh(geometry, material)
    // OpenSCAD uses mm; glTF uses meters.
    mesh.scale.setScalar(0.001)

    const scene = new THREE.Scene()
    scene.add(mesh)

    // Add a few basic lights so the exported GLB shades nicely even without an HDR environment.
    const lightA = new THREE.DirectionalLight(0xd6629e, 20) // pink
    lightA.position.set(1000, 1000, 1000) // north east, top
    lightA.lookAt(0, 0, 0)
    scene.add(lightA)

    const lightB = new THREE.DirectionalLight(0x5571a8, 20) // blue
    lightB.position.set(-1000, 1000, 1000) // north west, top
    lightB.lookAt(0, 0, 0)
    scene.add(lightB)

    const lightC = new THREE.DirectionalLight(0xbf86bb, 15) // purple
    lightC.position.set(0, -1000, -1000) // south, bottom
    lightC.lookAt(0, 0, 0)
    scene.add(lightC)

    const lightD = new THREE.DirectionalLight(0xbf86bb, 15) // purple
    lightD.position.set(0, -1000, 1000) // south, top
    lightD.lookAt(0, 0, 0)
    scene.add(lightD)

    return await new Promise((resolve, reject) => {
        const exporter = new GLTFExporter()
        exporter.parse(
            scene,
            (result) => {
                if (result instanceof ArrayBuffer) {
                    resolve(result)
                } else {
                    reject(new Error("Expected binary glTF (ArrayBuffer)"))
                }
            },
            (error) => reject(error),
            { binary: true },
        )
    })
}

async function createInstance() {
    const instance = await OpenSCAD({
        noInitialRun: true,
        print: logInfo,
        printErr: logInfo,
    })

    // OpenSCAD uses fontconfig for text() rendering.
    // In WASM there is no system fontconfig, so we ship a small config + fonts.
    // The Emscripten runtime exposes process environment via instance.ENV.
    // Set this before calling into OpenSCAD.
    if (instance.ENV) {
        instance.ENV.FONTCONFIG_PATH = "/fonts"
        instance.ENV.FONTCONFIG_FILE = "/fonts/fonts.conf"
        instance.ENV.HOME = "/tmp"
    }
    instance.FS.mkdirTree("/tmp/fontconfig")
    
    {
        const data = base64ToUint8Array("Ly8gM0QgUHJpbnRlciBGaWxhbWVudCBTcG9vbCBDbGlwIHdpdGggTGFiZWwgUGxhY2Vob2xkZXIKLy8gQSBwcmVzc3VyZS1maXQgY2xpcCB0aGF0IGF0dGFjaGVzIHRvIHRoZSBpbm5lciB3YWxscyBvZiBhIHNwb29sCi8vIENyZWF0ZWQgZm9yIGxhYmVsaW5nIHNwb29scwoKLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLy8gVVNFUiBDT05GSUdVUkFCTEUgUEFSQU1FVEVSUwovLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQoKLy8gU3Bvb2wgRGltZW5zaW9ucwpJbm5lcl9TcG9vbF9XaWR0aCA9IDU5OyAgICAgIC8vWzMwOjAuMTo3MF0KU3Bvb2xfV2FsbF9UaGlja25lc3NfTGVmdCA9IDMuNTsgICAvL1sxOjAuMTo3XQpTcG9vbF9XYWxsX1RoaWNrbmVzc19SaWdodCA9IDUuNTsgIC8vWzE6MC4xOjddCkJhY2tfVGV4dF9TdHJpbmcgPSAiIjsKCi8qIFtBZHZhbmNlZCBQYXJhbWV0ZXJzXSAqLwoKLy8gTGFiZWwgUGxhY2Vob2xkZXIgRGltZW5zaW9ucyAgCkxhYmVsX1dpZHRoID0gNDA7ICAgICAgICAgICAgICAgLy8gV2lkdGggb2YgbGFiZWwgYXJlYSAobW0pCkxhYmVsX0hlaWdodCA9IDMwOyAgICAgICAgICAgICAgLy8gSGVpZ2h0IG9mIGxhYmVsIGFyZWEgKG1tKQoKLy8gQ2xpcCBEaW1lbnNpb25zCkNsaXBfSGVpZ2h0ID0gMjA7ICAgICAgICAgICAgICAgLy8gSGVpZ2h0IG9mIGNsaXAgcG9ydGlvbnMgb3V0c2lkZSBsYWJlbCBhcmVhIChtbSkKQ2xpcF9Gcm9udF9UaGlja25lc3MgPSAzOyAgICAgICAvLyBUaGlja25lc3Mgb2YgZnJvbnQgZmFjZSAobGFiZWwgYW5kIGNsaXApIChtbSkKCi8vIElubmVyIEJyYWNlIChleHRlbmRzIGludG8gc3Bvb2wgaW50ZXJpb3IpCklubmVyX0JyYWNlX1RoaWNrbmVzcyA9IDI7ICAgICAgLy8gVGhpY2tuZXNzIG9mIGlubmVyIGJyYWNlIChtbSkKSW5uZXJfQnJhY2VfTGVuZ3RoID0gODsgICAgICAgICAvLyBIb3cgZmFyIGludG8gc3Bvb2wgaW50ZXJpb3IgKG1tKQoKLy8gT3V0ZXIgQnJhY2UgKGV4dGVuZHMgYWxvbmcgc3Bvb2wgZXh0ZXJpb3IpCk91dGVyX0JyYWNlX1RoaWNrbmVzcyA9IDEuNTsgICAgICAvLyBUaGlja25lc3Mgb2Ygb3V0ZXIgYnJhY2UgKG1tKSAKT3V0ZXJfQnJhY2VfTGVuZ3RoID0gNDsgICAgICAgICAvLyBIb3cgZmFyIGFsb25nIHNwb29sIGV4dGVyaW9yIChtbSkKCi8vIERlc2lnbiBQYXJhbWV0ZXJzClJvdW5kZWRfTGlwX1JhZGl1cyA9IDE7ICAgICAgICAgLy8gUmFkaXVzIGZvciByb3VuZGVkIHByZXNzdXJlIGxpcCAobW0pClRvbGVyYW5jZSA9IDAuMjsgICAgICAgICAgICAgICAgLy8gRml0IHRvbGVyYW5jZSAobW0pCgpCYWNrX1RleHRfU2l6ZSA9IDg7ICAgICAgICAgICAgIC8vIFNpemUgb2YgdGhlIHRleHQgb24gdGhlIGJhY2sgb2YgdGhlIGNsaXAgKG1tKQpCYWNrX1RleHRfSGVpZ2h0ID0gMC42OwoKLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLy8gQ0FMQ1VMQVRFRCBWQUxVRVMKLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KCi8vIFRvdGFsIGNsaXAgd2lkdGggc3BhbnMgdGhlIHNwb29sIG9wZW5pbmcgcGx1cyBicmFjZXMKT3V0ZXJfU3Bvb2xfV2lkdGggPSBJbm5lcl9TcG9vbF9XaWR0aCArIFNwb29sX1dhbGxfVGhpY2tuZXNzX0xlZnQgKyBTcG9vbF9XYWxsX1RoaWNrbmVzc19SaWdodDsKZWNobyhzdHIoIk91dGVyIFNwb29sIFdpZHRoOiAiLCBPdXRlcl9TcG9vbF9XaWR0aCkpOwpUb3RhbF9DbGlwX1dpZHRoID0gT3V0ZXJfU3Bvb2xfV2lkdGggKyAyKk91dGVyX0JyYWNlX1RoaWNrbmVzczsKVG90YWxfQ2xpcF9IZWlnaHQgPSBtaW4oTGFiZWxfSGVpZ2h0LCBDbGlwX0hlaWdodCk7CgovLyBDYWxjdWxhdGUgcG9zaXRpb25zCkxhYmVsX1hfT2Zmc2V0ID0gKFRvdGFsX0NsaXBfV2lkdGggLSBMYWJlbF9XaWR0aCkgLyAyOwpMYWJlbF9ZX09mZnNldCA9IG1heChDbGlwX0hlaWdodCwgTGFiZWxfSGVpZ2h0KS8yOwoKQ2xpcF9YX09mZnNldCA9IDA7CkNsaXBfWV9PZmZzZXQgPSBtYXgoQ2xpcF9IZWlnaHQsIExhYmVsX0hlaWdodCkvMjsKCi8vIElubmVyX0JyYWNlX1hfT2Zmc2V0ID0gLVRvdGFsX0NsaXBfV2lkdGgvMiArIE91dGVyX0JyYWNlX1RoaWNrbmVzcy8yICsgU3Bvb2xfV2FsbF9UaGlja25lc3MgKyBJbm5lcl9CcmFjZV9UaGlja25lc3MqMy8yOwpJbm5lcl9CcmFjZV9YX09mZnNldCA9IC1Jbm5lcl9TcG9vbF9XaWR0aC8yK0lubmVyX0JyYWNlX1RoaWNrbmVzcy8yOwpJbm5lcl9CcmFjZV9aX09mZnNldCA9IElubmVyX0JyYWNlX0xlbmd0aC8yK0NsaXBfRnJvbnRfVGhpY2tuZXNzLzI7Ck91dGVyX0JyYWNlX1hfT2Zmc2V0ID0gLVRvdGFsX0NsaXBfV2lkdGgvMitPdXRlcl9CcmFjZV9UaGlja25lc3MvMjsKT3V0ZXJfQnJhY2VfWl9PZmZzZXQgPSBPdXRlcl9CcmFjZV9MZW5ndGgvMitDbGlwX0Zyb250X1RoaWNrbmVzcy8yOwoKZWNobyhzdHIoIkNhbGN1bGF0ZWQgSW5uZXIgV2lkdGg6ICIsIDIqSW5uZXJfQnJhY2VfWF9PZmZzZXQtSW5uZXJfQnJhY2VfVGhpY2tuZXNzKSk7CgoKLy8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLy8gTUFJTiBHRU9NRVRSWQovLyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQoKc3Bvb2xfY2xpcCgpOwoKbW9kdWxlIHNwb29sX2NsaXAoKSB7CiAgICB1bmlvbigpIHsKICAgICAgICAvLyBNYWluIGNsaXAgYm9keSB3aXRoIGxhYmVsIHBsYWNlaG9sZGVyCiAgICAgICAgbWFpbl9jbGlwX2JvZHkoKTsKICAgICAgICAKICAgICAgICAvLyBJbm5lciBicmFjZSB3aXRoIHJvdW5kZWQgbGlwCiAgICAgICAgLy8gaW5uZXJfYnJhY2Vfd2l0aF9saXAoKTsKICAgICAgICAKICAgICAgICAvLyBPdXRlciBicmFjZQogICAgICAgIC8vIG91dGVyX2JyYWNlKCk7CiAgICB9Cn0KCi8vIE1haW4gY2xpcCBib2R5IGluY2x1ZGluZyBsYWJlbCBwbGFjZWhvbGRlcgptb2R1bGUgbWFpbl9jbGlwX2JvZHkoKSB7CiAgICB1bmlvbigpewogICAgICAgIGxhYmVsX2JvZHkoKTsKICAgICAgICBjbGlwX2Zyb250KCk7CiAgICAgICAgaW5uZXJfYnJhY2UoImxlZnQiKTsKICAgICAgICBpbm5lcl9icmFjZSgicmlnaHQiKTsKICAgICAgICBvdXRlcl9icmFjZSgibGVmdCIpOwogICAgICAgIG91dGVyX2JyYWNlKCJyaWdodCIpOwogICAgICAgIGJhY2tfdGV4dCgpOwogICAgfQp9Cgptb2R1bGUgbGFiZWxfYm9keSgpewogICAgdHJhbnNsYXRlKFswLCAwLCAwXSkgewogICAgICAgIGN1YmUoW0xhYmVsX1dpZHRoLCBMYWJlbF9IZWlnaHQsIENsaXBfRnJvbnRfVGhpY2tuZXNzXSwgY2VudGVyPXRydWUpOwogICAgfQp9Cgptb2R1bGUgY2xpcF9mcm9udCgpewogICAgdHJhbnNsYXRlKFswLCAwLCAwXSkgewogICAgICAgIGN1YmUoW1RvdGFsX0NsaXBfV2lkdGgsIENsaXBfSGVpZ2h0LCBDbGlwX0Zyb250X1RoaWNrbmVzc10sIGNlbnRlcj10cnVlKTsKICAgIH0KfQoKbW9kdWxlIGlubmVyX2JyYWNlKHNpZGUgPSAibGVmdCIpIHsKICAgIC8veE9mZnNldCA9IHNpZGU9PSJsZWZ0IiA/IElubmVyX0JyYWNlX1hfT2Zmc2V0IDogLUlubmVyX0JyYWNlX1hfT2Zmc2V0OwoKICAgIHNwb29sV2FsbFRoaWNrbmVzc0NvbWJpbmVkID0gU3Bvb2xfV2FsbF9UaGlja25lc3NfTGVmdCArIFNwb29sX1dhbGxfVGhpY2tuZXNzX1JpZ2h0OwogICAgc3Bvb2xXYWxsVGhpY2tuZXNzUGVyY2VudExlZnQgPSBTcG9vbF9XYWxsX1RoaWNrbmVzc19MZWZ0IC8gc3Bvb2xXYWxsVGhpY2tuZXNzQ29tYmluZWQ7CiAgICBzcG9vbFdhbGxUaGlja25lc3NQZXJjZW50UmlnaHQgPSBTcG9vbF9XYWxsX1RoaWNrbmVzc19SaWdodCAvIHNwb29sV2FsbFRoaWNrbmVzc0NvbWJpbmVkOwogICAgLy8gbGVmdFhPZmZzZXQgPSBPdXRlcl9CcmFjZV9UaGlja25lc3MgKyBJbm5lcl9CcmFjZV9UaGlja25lc3MtIFNwb29sX1dhbGxfVGhpY2tuZXNzX0xlZnQgLSBJbm5lcl9TcG9vbF9XaWR0aC8yOwogICAgLy9sZWZ0WE9mZnNldCA9IC0gSW5uZXJfU3Bvb2xfV2lkdGgvMiAtIElubmVyX0JyYWNlX1RoaWNrbmVzcy8yICsgU3Bvb2xfV2FsbF9UaGlja25lc3NfTGVmdC8yOwogICAgbGVmdFhPZmZzZXQgPSAtVG90YWxfQ2xpcF9XaWR0aC8yICsgT3V0ZXJfQnJhY2VfVGhpY2tuZXNzICsgU3Bvb2xfV2FsbF9UaGlja25lc3NfTGVmdDsKICAgIC8vcmlnaHRYT2Zmc2V0ID0gSW5uZXJfU3Bvb2xfV2lkdGgvMiArIFNwb29sX1dhbGxfVGhpY2tuZXNzX1JpZ2h0OwogICAgLy8gcmlnaHRYT2Zmc2V0ID0gSW5uZXJfU3Bvb2xfV2lkdGgvMiArIElubmVyX0JyYWNlX1RoaWNrbmVzcy8yIC0gU3Bvb2xfV2FsbF9UaGlja25lc3NfUmlnaHQvMjsKICAgIHJpZ2h0WE9mZnNldCA9IFRvdGFsX0NsaXBfV2lkdGgvMiAtIE91dGVyX0JyYWNlX1RoaWNrbmVzcyAtIFNwb29sX1dhbGxfVGhpY2tuZXNzX1JpZ2h0IC0gSW5uZXJfQnJhY2VfVGhpY2tuZXNzLzI7CiAgICB4T2Zmc2V0ID0gc2lkZT09ImxlZnQiID8gbGVmdFhPZmZzZXQgOiByaWdodFhPZmZzZXQ7CgogICAgYyA9IHNpZGU9PSJsZWZ0IiA/ICJyZWQiIDogImJsdWUiOwogICAgdHJhbnNsYXRlKFt4T2Zmc2V0LCAwLCBJbm5lcl9CcmFjZV9aX09mZnNldF0pIHsKICAgICAgICBjb2xvcihjKSBjdWJlKFtJbm5lcl9CcmFjZV9UaGlja25lc3MsIENsaXBfSGVpZ2h0LCBJbm5lcl9CcmFjZV9MZW5ndGhdLCBjZW50ZXI9dHJ1ZSk7CiAgICB9ICAgCiAgICAvL3hPZmZzZXRSb3VuZGVkTGlwID0gc2lkZT09ImxlZnQiID8gSW5uZXJfQnJhY2VfWF9PZmZzZXQgLSBJbm5lcl9CcmFjZV9UaGlja25lc3MvMiA6IC1Jbm5lcl9CcmFjZV9YX09mZnNldCArIElubmVyX0JyYWNlX1RoaWNrbmVzcy8yOwogICAgeE9mZnNldFJvdW5kZWRMaXAgPSBzaWRlPT0ibGVmdCIgPyBsZWZ0WE9mZnNldCAtIElubmVyX0JyYWNlX1RoaWNrbmVzcy8yIDogcmlnaHRYT2Zmc2V0ICsgSW5uZXJfQnJhY2VfVGhpY2tuZXNzLzI7CiAgICB0cmFuc2xhdGUoW3hPZmZzZXRSb3VuZGVkTGlwLCAwLCBJbm5lcl9CcmFjZV9MZW5ndGhdKSB7CiAgICAgICAgcm90YXRlKFs5MCw5MCwwXSl7CiAgICAgICAgICAgIGN5bGluZGVyKGg9Q2xpcF9IZWlnaHQsIHI9Um91bmRlZF9MaXBfUmFkaXVzLzIsIGNlbnRlcj10cnVlKTsKICAgICAgICB9CiAgICB9CiAgICAKfQoKbW9kdWxlIG91dGVyX2JyYWNlKHNpZGUgPSAibGVmdCIpIHsKICAgIHhPZmZzZXQgPSBzaWRlPT0ibGVmdCIgPyBPdXRlcl9CcmFjZV9YX09mZnNldCA6IC1PdXRlcl9CcmFjZV9YX09mZnNldDsKICAgIHRyYW5zbGF0ZShbeE9mZnNldCwgMCwgT3V0ZXJfQnJhY2VfWl9PZmZzZXRdKSB7CiAgICAgICAgY3ViZShbT3V0ZXJfQnJhY2VfVGhpY2tuZXNzLCBDbGlwX0hlaWdodCwgT3V0ZXJfQnJhY2VfTGVuZ3RoXSwgY2VudGVyPXRydWUpOwogICAgfQp9CgoKLy8gSW5uZXIgYnJhY2UgdGhhdCBleHRlbmRzIGludG8gdGhlIHNwb29sIGludGVyaW9yIHdpdGggcm91bmRlZCBwcmVzc3VyZSBsaXAKbW9kdWxlIGlubmVyX2JyYWNlX3dpdGhfbGlwKCkgewogICAgdHJhbnNsYXRlKFswLCAwLCAwXSkgewogICAgICAgIHVuaW9uKCkgewogICAgICAgICAgICAvLyBNYWluIGlubmVyIGJyYWNlIGJvZHkKICAgICAgICAgICAgY3ViZShbSW5uZXJfQnJhY2VfTGVuZ3RoLCBUb3RhbF9DbGlwX0hlaWdodCwgSW5uZXJfQnJhY2VfVGhpY2tuZXNzXSk7CiAgICAgICAgICAgIAogICAgICAgICAgICAvLyBSb3VuZGVkIHByZXNzdXJlIGxpcCBhdCB0aGUgZW5kCiAgICAgICAgICAgIHRyYW5zbGF0ZShbSW5uZXJfQnJhY2VfTGVuZ3RoLCAwLCBJbm5lcl9CcmFjZV9UaGlja25lc3NdKSB7CiAgICAgICAgICAgICAgICBsaW5lYXJfZXh0cnVkZShoZWlnaHQgPSBUb3RhbF9DbGlwX0hlaWdodCkgewogICAgICAgICAgICAgICAgICAgIGludGVyc2VjdGlvbigpIHsKICAgICAgICAgICAgICAgICAgICAgICAgY2lyY2xlKHIgPSBSb3VuZGVkX0xpcF9SYWRpdXMpOwogICAgICAgICAgICAgICAgICAgICAgICBzcXVhcmUoW1JvdW5kZWRfTGlwX1JhZGl1cywgUm91bmRlZF9MaXBfUmFkaXVzICogMl0sIGNlbnRlciA9IGZhbHNlKTsKICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAvLyBSb3RhdGUgdGhlIGxpcCB0byBmYWNlIHRoZSBjb3JyZWN0IGRpcmVjdGlvbgogICAgICAgICAgICAgICAgcm90YXRlKFs5MCwgMCwgMF0pIHsKICAgICAgICAgICAgICAgICAgICB0cmFuc2xhdGUoWzAsIDAsIC1Ub3RhbF9DbGlwX0hlaWdodF0pIHsKICAgICAgICAgICAgICAgICAgICAgICAgbGluZWFyX2V4dHJ1ZGUoaGVpZ2h0ID0gVG90YWxfQ2xpcF9IZWlnaHQpIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgIGludGVyc2VjdGlvbigpIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBjaXJjbGUociA9IFJvdW5kZWRfTGlwX1JhZGl1cyk7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgc3F1YXJlKFtSb3VuZGVkX0xpcF9SYWRpdXMsIFJvdW5kZWRfTGlwX1JhZGl1c10sIGNlbnRlciA9IGZhbHNlKTsKICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgfQogICAgICAgIH0KICAgIH0KfQoKLy8gRW5oYW5jZWQgaW5uZXIgYnJhY2Ugd2l0aCBwcm9wZXIgcm91bmRlZCBsaXAgZm9yIHByZXNzdXJlIGZpdHRpbmcKbW9kdWxlIGlubmVyX2JyYWNlX3dpdGhfbGlwX2VuaGFuY2VkKCkgewogICAgdHJhbnNsYXRlKFswLCAwLCAwXSkgewogICAgICAgIHVuaW9uKCkgewogICAgICAgICAgICAvLyBNYWluIGlubmVyIGJyYWNlIGJvZHkKICAgICAgICAgICAgY3ViZShbSW5uZXJfQnJhY2VfTGVuZ3RoLCBUb3RhbF9DbGlwX0hlaWdodCwgSW5uZXJfQnJhY2VfVGhpY2tuZXNzXSk7CiAgICAgICAgICAgIAogICAgICAgICAgICAvLyBSb3VuZGVkIHByZXNzdXJlIGxpcCAtIGNyZWF0ZXMgaW53YXJkIHByZXNzdXJlIG9uIHNwb29sIHdhbGwKICAgICAgICAgICAgdHJhbnNsYXRlKFtJbm5lcl9CcmFjZV9MZW5ndGgsIDAsIDBdKSB7CiAgICAgICAgICAgICAgICByb3RhdGUoWzAsIDAsIDBdKSB7CiAgICAgICAgICAgICAgICAgICAgbGluZWFyX2V4dHJ1ZGUoaGVpZ2h0ID0gVG90YWxfQ2xpcF9IZWlnaHQpIHsKICAgICAgICAgICAgICAgICAgICAgICAgaHVsbCgpIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgIC8vIEJhc2Ugb2YgdGhlIGxpcAogICAgICAgICAgICAgICAgICAgICAgICAgICAgdHJhbnNsYXRlKFswLCAwXSkgc3F1YXJlKFswLjEsIElubmVyX0JyYWNlX1RoaWNrbmVzc10pOwogICAgICAgICAgICAgICAgICAgICAgICAgICAgLy8gUm91bmRlZCBlbmQgZXh0ZW5kaW5nIGlud2FyZAogICAgICAgICAgICAgICAgICAgICAgICAgICAgdHJhbnNsYXRlKFtSb3VuZGVkX0xpcF9SYWRpdXMgLSAwLjUsIElubmVyX0JyYWNlX1RoaWNrbmVzcy8yXSkgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgY2lyY2xlKHIgPSBSb3VuZGVkX0xpcF9SYWRpdXMvMik7CiAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgIH0KICAgICAgICB9CiAgICB9Cn0KbW9kdWxlIGJhY2tfdGV4dCgpewogICAgdGV4dFNpemUgPSBCYWNrX1RleHRfU2l6ZTsKICAgIHRleHRIZWlnaHQgPSBCYWNrX1RleHRfSGVpZ2h0OwogICAgaWYoQmFja19UZXh0X1N0cmluZyl7CiAgICAgICAgdHJhbnNsYXRlKFswLCArdGV4dFNpemUvMisxLCBDbGlwX0Zyb250X1RoaWNrbmVzcy8yXSkgewogICAgICAgICAgICBsaW5lYXJfZXh0cnVkZShoZWlnaHQgPSB0ZXh0SGVpZ2h0KSB7CiAgICAgICAgICAgICAgICB0ZXh0KEJhY2tfVGV4dF9TdHJpbmcsIHNpemUgPSB0ZXh0U2l6ZSwgaGFsaWduID0gImNlbnRlciIsIHZhbGlnbiA9ICJjZW50ZXIiLCBmb250PSJBcmlhbDpzdHlsZT1Cb2xkIik7CiAgICAgICAgICAgIH0KICAgICAgICB9CiAgICAgICAgdHJhbnNsYXRlKFswLCAtdGV4dFNpemUvMi0xLCBDbGlwX0Zyb250X1RoaWNrbmVzcy8yXSkgewogICAgICAgICAgICBsaW5lYXJfZXh0cnVkZShoZWlnaHQgPSB0ZXh0SGVpZ2h0KSB7CiAgICAgICAgICAgICAgICB0ZXh0KHN0cihJbm5lcl9TcG9vbF9XaWR0aCwgIiAtICIsIFNwb29sX1dhbGxfVGhpY2tuZXNzX0xlZnQsICIgLSAiLCBTcG9vbF9XYWxsX1RoaWNrbmVzc19SaWdodCksIHNpemUgPSB0ZXh0U2l6ZSwgaGFsaWduID0gImNlbnRlciIsIHZhbGlnbiA9ICJjZW50ZXIiLCBmb250PSJBcmlhbDpzdHlsZT1Cb2xkIik7CiAgICAgICAgICAgIH0KICAgICAgICB9CiAgICB9IGVsc2UgewogICAgICAgIHRyYW5zbGF0ZShbMCwgK3RleHRTaXplLzIrMSwgQ2xpcF9Gcm9udF9UaGlja25lc3MvMl0pIHsKICAgICAgICAgICAgbGluZWFyX2V4dHJ1ZGUoaGVpZ2h0ID0gdGV4dEhlaWdodCkgewogICAgICAgICAgICAgICAgdGV4dChzdHIoSW5uZXJfU3Bvb2xfV2lkdGgsIiBtbSIpLCBzaXplID0gdGV4dFNpemUsIGhhbGlnbiA9ICJjZW50ZXIiLCB2YWxpZ24gPSAiY2VudGVyIiwgZm9udD0iQXJpYWw6c3R5bGU9Qm9sZCIpOwogICAgICAgICAgICB9CiAgICAgICAgfQogICAgICAgIHRyYW5zbGF0ZShbMCwgLXRleHRTaXplLzItMSwgQ2xpcF9Gcm9udF9UaGlja25lc3MvMl0pIHsKICAgICAgICAgICAgbGluZWFyX2V4dHJ1ZGUoaGVpZ2h0ID0gdGV4dEhlaWdodCkgewogICAgICAgICAgICAgICAgdGV4dChzdHIoU3Bvb2xfV2FsbF9UaGlja25lc3NfTGVmdCwgIiA8LT4gIiwgU3Bvb2xfV2FsbF9UaGlja25lc3NfUmlnaHQsICIiKSwgc2l6ZSA9IHRleHRTaXplLCBoYWxpZ24gPSAiY2VudGVyIiwgdmFsaWduID0gImNlbnRlciIpOwogICAgICAgICAgICB9CiAgICAgICAgfQogICAgfQogICAgCn0K")
        logInfo("Loading /Spool-Dual-Clip-Label.scad (" + data.length + " bytes)")
        const parent = "/Spool-Dual-Clip-Label.scad".substring(0, "/Spool-Dual-Clip-Label.scad".lastIndexOf("/"))
        if (parent) {
            instance.FS.mkdirTree(parent)
        }
        instance.FS.writeFile("/Spool-Dual-Clip-Label.scad", data)
    }
    
    {
        const data = base64ToUint8Array("PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIGZvbnRjb25maWcgU1lTVEVNICJ1cm46Zm9udGNvbmZpZzpmb250cy5kdGQiPgo8Zm9udGNvbmZpZz4KICA8ZGlyPi9mb250czwvZGlyPgogIDxjYWNoZWRpcj4vdG1wL2ZvbnRjb25maWc8L2NhY2hlZGlyPgo8L2ZvbnRjb25maWc+Cg==")
        logInfo("Loading /fonts/fonts.conf (" + data.length + " bytes)")
        const parent = "/fonts/fonts.conf".substring(0, "/fonts/fonts.conf".lastIndexOf("/"))
        if (parent) {
            instance.FS.mkdirTree(parent)
        }
        instance.FS.writeFile("/fonts/fonts.conf", data)
    }
    
    return instance
}

function normalizeInputPath(input) {
    const inputPath = String(input || "")
    if (!inputPath) {
        throw new Error("Missing input SCAD path")
    }
    const normalized = inputPath.startsWith("/") ? inputPath : "/" + inputPath
    if (!INPUTS.includes(normalized)) {
        throw new Error("Unknown input SCAD path: " + normalized)
    }
    return normalized
}

async function renderOnce({ input, customization, additionalParamNames }) {
    const instance = await createInstance()
    const inputPath = normalizeInputPath(input)

    const additionalParamNameSet = new Set(
        Array.isArray(additionalParamNames)
            ? additionalParamNames.filter((x) => typeof x === "string")
            : [],
    )

    const stringifiedParameters = {}
    const additionalDefinitions = []
    for (const [k, v] of Object.entries(customization)) {
        if (additionalParamNameSet.has(k)) {
            // -D expects an OpenSCAD expression; JSON happens to be close enough for our value types.
            additionalDefinitions.push(`${k}=${JSON.stringify(v)}`)
        } else {
            // Parameter set files use unquoted strings for string parameters.
            stringifiedParameters[k] = typeof v === "string" ? v : JSON.stringify(v)
        }
    }
    logInfo("Parameters:", stringifiedParameters)
    logInfo("Additional -D:", additionalDefinitions)
    instance.FS.writeFile(
        "/parameters.json",
        JSON.stringify({
            fileFormatVersion: 1,
            parameterSets: {
                single: stringifiedParameters,
            },
        }),
    )

    const output = "/output.stl"
    try {
        instance.FS.unlink(output)
    } catch (e) {
        // ignore
    }
    const args = [
        inputPath,
        "-o",
        output,
        "--export-format=binstl",
        "-p",
        "/parameters.json",
        "-P",
        "single",
    ]
    for (const def of additionalDefinitions) {
        args.push("-D", def)
    }
    try {
        instance.callMain(args)
        const stlBytes = instance.FS.readFile(output)
        const glb = await stlBytesToGlb(stlBytes)
        self.postMessage({
            type: "ok",
            glb: glb,
            stl: stlBytes,
        })
    } catch (e) {
        logError(e)
        self.postMessage({
            type: "error",
            error: formatErrorForMessage(e),
            stack: String(e && e.stack ? e.stack : ""),
            log: currentLog,
        })
    }
}

self.addEventListener("message", (event) => {
    const msg = event && event.data
    if (!msg || typeof msg !== "object") {
        return
    }

    // Serialize OpenSCAD runs to avoid concurrent FS/wasm access.
    runQueue = runQueue.then(async () => {
        if (msg.type !== "render") {
            return
        }
        currentLog = ""
        currentLogTruncated = false
        await renderOnce({
            input: msg.input,
            customization: msg.customization,
            additionalParamNames: msg.additionalParamNames,
        })
    })
    runQueue.catch((e) => {
        logError(e)
        self.postMessage({
            type: "error",
            error: formatErrorForMessage(e),
            stack: String(e && e.stack ? e.stack : ""),
            log: currentLog,
        })
    })
})