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

const INPUTS = ["/Electric Fence Post Mount.scad"]

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
        const data = base64ToUint8Array("aW5jbHVkZSA8VGhyZWFkQm9hcmRzL2xpYi90Yl9zY3Jld3Muc2NhZD47CgoKLyogW0JveCBQYXJhbWV0ZXJzXSAqLwpCb3hfV2lkdGhfWCA9IDI1OyAvLyBbMTA6MC4xOjIwMF0KQm94X1dpZHRoX1kgPSAyMDsgLy8gWzEwOjAuMToyMDBdCkJveF9IZWlnaHQgPSAyNzsgLy8gWzEwOjE6MjAwXQpCYXNlX1RoaWNrbmVzcyA9IDI7IC8vIFswLjU6MC41OjEwXQoKLyogW1NpZGUgMSBQYXJhbWV0ZXJzXSAqLwpTaWRlMV9UaGlja25lc3MgPSAwOyAvLyBbMC41OjAuNToxMF0KU2lkZTFfQ29ubmVjdG9yX1R5cGUgPSAidGJzY3JldyI7IC8vIFtub25lOk5vbmUsIG53aXJlOk4tU3R5bGUgV2lyZSBDbGlwLCB3d2lyZTpXLVN0eWxlIFdpcmUgQ2xpcCwgdGJzY3JldzpUaHJlYWQgQm9hcmQgU2NyZXcgSG9sZSwgc2xpZGVsb2NrOlNsaWRlIExvY2sgU2xvdCwgaG9vazpTaW1wbGUgSG9vaywgb3BlbjpPcGVuaW5nLCBwb3N0Y2xpcDpQb3N0IE1vdW50aW5nIENsaXBdCgovKiBbU2lkZSAyIFBhcmFtZXRlcnNdICovClNpZGUyX1RoaWNrbmVzcyA9IDA7IC8vIFswLjU6MC41OjEwXQpTaWRlMl9Db25uZWN0b3JfVHlwZSA9ICJzbGlkZWxvY2siOyAvLyBbbm9uZTpOb25lLCBud2lyZTpOLVN0eWxlIFdpcmUgQ2xpcCwgd3dpcmU6Vy1TdHlsZSBXaXJlIENsaXAsIHRic2NyZXc6VGhyZWFkIEJvYXJkIFNjcmV3IEhvbGUsIHNsaWRlbG9jazpTbGlkZSBMb2NrIFNsb3QsIGhvb2s6U2ltcGxlIEhvb2ssIG9wZW46T3BlbmluZywgcG9zdGNsaXA6UG9zdCBNb3VudGluZyBDbGlwXQovKiBbU2lkZSAzIFBhcmFtZXRlcnNdICovClNpZGUzX1RoaWNrbmVzcyA9IDA7IC8vIFswLjU6MC41OjEwXQpTaWRlM19Db25uZWN0b3JfVHlwZSA9ICJ3d2lyZSI7IC8vIFtub25lOk5vbmUsIG53aXJlOk4tU3R5bGUgV2lyZSBDbGlwLCB3d2lyZTpXLVN0eWxlIFdpcmUgQ2xpcCwgdGJzY3JldzpUaHJlYWQgQm9hcmQgU2NyZXcgSG9sZSwgc2xpZGVsb2NrOlNsaWRlIExvY2sgU2xvdCwgaG9vazpTaW1wbGUgSG9vaywgb3BlbjpPcGVuaW5nLCBwb3N0Y2xpcDpQb3N0IE1vdW50aW5nIENsaXBdCgovKiBbU2lkZSA0IFBhcmFtZXRlcnNdICovClNpZGU0X1RoaWNrbmVzcyA9IDA7IC8vIFswLjU6MC41OjEwXQpTaWRlNF9Db25uZWN0b3JfVHlwZSA9ICJwb3N0Y2xpcCI7IC8vIFtub25lOk5vbmUsIG53aXJlOk4tU3R5bGUgV2lyZSBDbGlwLCB3d2lyZTpXLVN0eWxlIFdpcmUgQ2xpcCwgdGJzY3JldzpUaHJlYWQgQm9hcmQgU2NyZXcgSG9sZSwgc2xpZGVsb2NrOlNsaWRlIExvY2sgU2xvdCwgaG9vazpTaW1wbGUgSG9vaywgb3BlbjpPcGVuaW5nLCBwb3N0Y2xpcDpQb3N0IE1vdW50aW5nIENsaXBdCgovKiBbSGlkZGVuXSAqLwovLyBCb3hfRGVwdGggPSAzMjsgLy8gWzEwOjE6MTAwXQpTbG90X0NoYW5uZWxfV2lkdGhfTGFyZ2VfRW5kID0gMjA7ClNsb3RfQ2hhbm5lbF9XaWR0aF9TbWFsbF9FbmQgPSAxNTsKU2xvdF9EZXB0aCA9IDQ7CgoKCmRyYXdCb3goKTsKLy8gYm94U2lkZVBvc3RDbGlwKGdlbmVyYXRlRmFzdGVuZXIgPSBmYWxzZSk7Cgptb2R1bGUgZHJhd0JveCgpewogICAgZ2hvc3RMYWJlbFNpemUgPSAzOwogICAgZ2hvc3RMYWJlbFggPSBtYXgoQm94X1dpZHRoX1gsIEJveF9XaWR0aF9ZKS8yOwogICAgZ2hvc3RMYWJlbFogPSAtODsKICAgIGdob3N0TGFiZWxDb2xvciA9ICJyZWQiOwogICAgcm90YXRlKFswLDE4MCwwXSl7CiAgICAgICAgdW5pb24oKXsKICAgICAgICAgICAgLy8gU2lkZSAxCiAgICAgICAgICAgIHRyYW5zbGF0ZShbMCwgLUJveF9XaWR0aF9ZLzIgLSBTaWRlMV9UaGlja25lc3MvMiwgMF0pewogICAgICAgICAgICAgICAgdHJhbnNsYXRlKFtnaG9zdExhYmVsWCwgLShCYXNlX1RoaWNrbmVzcytTaWRlMV9UaGlja25lc3MpLzIsIGdob3N0TGFiZWxaXSkgcm90YXRlKFstOTAsMCwxODBdKSBjb2xvcihnaG9zdExhYmVsQ29sb3IpIHRleHQoIjEiLCBzaXplPWdob3N0TGFiZWxTaXplKTsKICAgICAgICAgICAgICAgIGlmKFNpZGUxX0Nvbm5lY3Rvcl9UeXBlID09ICJub25lIil7CiAgICAgICAgICAgICAgICAgICAgYm94U2lkZUZsYXQod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlMV9UaGlja25lc3MsIHNpZGU9MSk7CiAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTFfQ29ubmVjdG9yX1R5cGUgPT0gIm53aXJlIil7CiAgICAgICAgICAgICAgICAgICAgYm94U2lkZVdpcmVDbGlwTlR5cGUod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlMV9UaGlja25lc3MsIHNpZGU9MSk7CiAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTFfQ29ubmVjdG9yX1R5cGUgPT0gInRic2NyZXciKXsKICAgICAgICAgICAgICAgICAgICBib3hTaWRlVEJTY3Jld0hvbGUod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlMV9UaGlja25lc3MsIHNpZGU9MSk7CiAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTFfQ29ubmVjdG9yX1R5cGUgPT0gInNsaWRlbG9jayIpewogICAgICAgICAgICAgICAgICAgIGJveFNpZGVTbGlkZUxvY2tTbG90KHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTFfVGhpY2tuZXNzLCBzaWRlPTEpOwogICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGUxX0Nvbm5lY3Rvcl9UeXBlID09ICJob29rIil7CiAgICAgICAgICAgICAgICAgICAgYm94U2lkZVNpbXBsZUhvb2sod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlMV9UaGlja25lc3MsIHNpZGU9MSk7CiAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTFfQ29ubmVjdG9yX1R5cGUgPT0gInd3aXJlIil7CiAgICAgICAgICAgICAgICAgICAgYm94U2lkZVdpcmVDbGlwV1R5cGUod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlMV9UaGlja25lc3MsIHNpZGU9MSk7CiAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTFfQ29ubmVjdG9yX1R5cGUgPT0gIm9wZW4iKXsKICAgICAgICAgICAgICAgICAgICBib3hTaWRlRmxhdCh3YWxsVGhpY2tuZXNzPTAsIHNpZGU9MSk7CiAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTFfQ29ubmVjdG9yX1R5cGUgPT0gInBvc3RjbGlwIil7CiAgICAgICAgICAgICAgICAgICAgYm94U2lkZVBvc3RDbGlwKHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTFfVGhpY2tuZXNzLCBzaWRlPTEpOwogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgICAgIC8vIFNpZGUgMgogICAgICAgICAgICB0cmFuc2xhdGUoW0JveF9XaWR0aF9YLzIgKyBTaWRlMl9UaGlja25lc3MvMiwgMCwgMF0pewogICAgICAgICAgICAgICAgcm90YXRlKFswLDAsOTBdKXsKICAgICAgICAgICAgICAgICAgICB0cmFuc2xhdGUoW2dob3N0TGFiZWxYLCAtKEJhc2VfVGhpY2tuZXNzK1NpZGUyX1RoaWNrbmVzcykvMiwgZ2hvc3RMYWJlbFpdKSByb3RhdGUoWy05MCwwLDE4MF0pIGNvbG9yKGdob3N0TGFiZWxDb2xvcikgdGV4dCgiMiIsIHNpemU9Z2hvc3RMYWJlbFNpemUpOwogICAgICAgICAgICAgICAgICAgIGlmKFNpZGUyX0Nvbm5lY3Rvcl9UeXBlID09ICJub25lIil7CiAgICAgICAgICAgICAgICAgICAgICAgIGJveFNpZGVGbGF0KHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTJfVGhpY2tuZXNzLCBzaWRlPTIpOwogICAgICAgICAgICAgICAgICAgIH0gZWxzZSBpZihTaWRlMl9Db25uZWN0b3JfVHlwZSA9PSAibndpcmUiKXsKICAgICAgICAgICAgICAgICAgICAgICAgYm94U2lkZVdpcmVDbGlwTlR5cGUod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlMl9UaGlja25lc3MsIHNpZGU9Mik7CiAgICAgICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGUyX0Nvbm5lY3Rvcl9UeXBlID09ICJ0YnNjcmV3Iil7CiAgICAgICAgICAgICAgICAgICAgICAgIGJveFNpZGVUQlNjcmV3SG9sZSh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGUyX1RoaWNrbmVzcywgc2lkZT0yKTsKICAgICAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTJfQ29ubmVjdG9yX1R5cGUgPT0gInNsaWRlbG9jayIpewogICAgICAgICAgICAgICAgICAgICAgICBib3hTaWRlU2xpZGVMb2NrU2xvdCh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGUyX1RoaWNrbmVzcywgc2lkZT0yKTsKICAgICAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTJfQ29ubmVjdG9yX1R5cGUgPT0gImhvb2siKXsKICAgICAgICAgICAgICAgICAgICAgICAgYm94U2lkZVNpbXBsZUhvb2sod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlMl9UaGlja25lc3MsIHNpZGU9Mik7CiAgICAgICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGUyX0Nvbm5lY3Rvcl9UeXBlID09ICJ3d2lyZSIpewogICAgICAgICAgICAgICAgICAgICAgICBib3hTaWRlV2lyZUNsaXBXVHlwZSh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGUyX1RoaWNrbmVzcywgc2lkZT0yKTsKICAgICAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTJfQ29ubmVjdG9yX1R5cGUgPT0gInBvc3RjbGlwIil7CiAgICAgICAgICAgICAgICAgICAgICAgIGJveFNpZGVQb3N0Q2xpcCh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGUyX1RoaWNrbmVzcywgc2lkZT0yKTsKICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgIH0KICAgICAgICAgICAgLy8gU2lkZSAzCiAgICAgICAgICAgIHRyYW5zbGF0ZShbMCwgQm94X1dpZHRoX1kvMiArIFNpZGUzX1RoaWNrbmVzcy8yLCAwXSl7CiAgICAgICAgICAgICAgICByb3RhdGUoWzAsMCwxODBdKXsKICAgICAgICAgICAgICAgICAgICB0cmFuc2xhdGUoW2dob3N0TGFiZWxYLCAtKEJhc2VfVGhpY2tuZXNzK1NpZGUzX1RoaWNrbmVzcykvMiwgZ2hvc3RMYWJlbFpdKSByb3RhdGUoWy05MCwwLDE4MF0pIGNvbG9yKGdob3N0TGFiZWxDb2xvcikgdGV4dCgiMyIsIHNpemU9Z2hvc3RMYWJlbFNpemUpOwogICAgICAgICAgICAgICAgICAgIGlmKFNpZGUzX0Nvbm5lY3Rvcl9UeXBlID09ICJub25lIil7CiAgICAgICAgICAgICAgICAgICAgICAgIGJveFNpZGVGbGF0KHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTNfVGhpY2tuZXNzLCBzaWRlPTMpOwogICAgICAgICAgICAgICAgICAgIH0gZWxzZSBpZihTaWRlM19Db25uZWN0b3JfVHlwZSA9PSAibndpcmUiKXsKICAgICAgICAgICAgICAgICAgICAgICAgYm94U2lkZVdpcmVDbGlwTlR5cGUod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlM19UaGlja25lc3MsIHNpZGU9Myk7CiAgICAgICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGUzX0Nvbm5lY3Rvcl9UeXBlID09ICJ0YnNjcmV3Iil7CiAgICAgICAgICAgICAgICAgICAgICAgIGJveFNpZGVUQlNjcmV3SG9sZSh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGUzX1RoaWNrbmVzcywgc2lkZT0zKTsKICAgICAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTNfQ29ubmVjdG9yX1R5cGUgPT0gInNsaWRlbG9jayIpewogICAgICAgICAgICAgICAgICAgICAgICBib3hTaWRlU2xpZGVMb2NrU2xvdCh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGUzX1RoaWNrbmVzcywgc2lkZT0zKTsKICAgICAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTNfQ29ubmVjdG9yX1R5cGUgPT0gImhvb2siKXsKICAgICAgICAgICAgICAgICAgICAgICAgYm94U2lkZVNpbXBsZUhvb2sod2FsbFRoaWNrbmVzcz1CYXNlX1RoaWNrbmVzcytTaWRlM19UaGlja25lc3MsIHNpZGU9Myk7CiAgICAgICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGUzX0Nvbm5lY3Rvcl9UeXBlID09ICJ3d2lyZSIpewogICAgICAgICAgICAgICAgICAgICAgICBib3hTaWRlV2lyZUNsaXBXVHlwZSh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGUzX1RoaWNrbmVzcywgc2lkZT0zKTsKICAgICAgICAgICAgICAgICAgICB9IGVsc2UgaWYoU2lkZTNfQ29ubmVjdG9yX1R5cGUgPT0gInBvc3RjbGlwIil7CiAgICAgICAgICAgICAgICAgICAgYm94U2lkZVBvc3RDbGlwKHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTNfVGhpY2tuZXNzLCBzaWRlPTMpOwogICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgfQogICAgICAgIC8vIFNpZGUgNAogICAgICAgIHRyYW5zbGF0ZShbLUJveF9XaWR0aF9YLzIgLSBTaWRlNF9UaGlja25lc3MvMiwgMCwgMF0pewogICAgICAgICAgICByb3RhdGUoWzAsMCwtOTBdKXsKICAgICAgICAgICAgICAgIHRyYW5zbGF0ZShbZ2hvc3RMYWJlbFgsIC0oQmFzZV9UaGlja25lc3MrU2lkZTRfVGhpY2tuZXNzKS8yLCBnaG9zdExhYmVsWl0pIHJvdGF0ZShbLTkwLDAsMTgwXSkgY29sb3IoZ2hvc3RMYWJlbENvbG9yKSB0ZXh0KCI0Iiwgc2l6ZT1naG9zdExhYmVsU2l6ZSk7CiAgICAgICAgICAgICAgICBpZihTaWRlNF9Db25uZWN0b3JfVHlwZSA9PSAibm9uZSIpewogICAgICAgICAgICAgICAgICAgIGJveFNpZGVGbGF0KHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTRfVGhpY2tuZXNzLCBzaWRlPTQpOwogICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGU0X0Nvbm5lY3Rvcl9UeXBlID09ICJud2lyZSIpewogICAgICAgICAgICAgICAgICAgIGJveFNpZGVXaXJlQ2xpcE5UeXBlKHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTRfVGhpY2tuZXNzLCBzaWRlPTQpOwogICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGU0X0Nvbm5lY3Rvcl9UeXBlID09ICJ0YnNjcmV3Iil7CiAgICAgICAgICAgICAgICAgICAgYm94U2lkZVRCU2NyZXdIb2xlKHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTRfVGhpY2tuZXNzLCBzaWRlPTQpOwogICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGU0X0Nvbm5lY3Rvcl9UeXBlID09ICJzbGlkZWxvY2siKXsKICAgICAgICAgICAgICAgICAgICBib3hTaWRlU2xpZGVMb2NrU2xvdCh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGU0X1RoaWNrbmVzcywgc2lkZT00KTsKICAgICAgICAgICAgICAgIH0gZWxzZSBpZihTaWRlNF9Db25uZWN0b3JfVHlwZSA9PSAiaG9vayIpewogICAgICAgICAgICAgICAgICAgIGJveFNpZGVTaW1wbGVIb29rKHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTRfVGhpY2tuZXNzLCBzaWRlPTQpOwogICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGU0X0Nvbm5lY3Rvcl9UeXBlID09ICJ3d2lyZSIpewogICAgICAgICAgICAgICAgICAgIGJveFNpZGVXaXJlQ2xpcFdUeXBlKHdhbGxUaGlja25lc3M9QmFzZV9UaGlja25lc3MrU2lkZTRfVGhpY2tuZXNzLCBzaWRlPTQpOwogICAgICAgICAgICAgICAgfSBlbHNlIGlmKFNpZGU0X0Nvbm5lY3Rvcl9UeXBlID09ICJwb3N0Y2xpcCIpewogICAgICAgICAgICAgICAgICAgIGJveFNpZGVQb3N0Q2xpcCh3YWxsVGhpY2tuZXNzPUJhc2VfVGhpY2tuZXNzK1NpZGU0X1RoaWNrbmVzcywgc2lkZT00KTsKICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgfQogICAgICAgIH0KICAgIH0KICAgIAp9CgoKCgogICAgICAgICAgICAgICAgCgptb2R1bGUgYm94U2lkZVRCU2NyZXdIb2xlKHdhbGxUaGlja25lc3M9Miwgc2lkZT0xKXsKICAgIHdpZHRoID0gKHNpZGUgPT0gMSB8fCBzaWRlID09IDMpID8gQm94X1dpZHRoX1ggOiBCb3hfV2lkdGhfWTsKICAgIHJvdGF0ZShbOTAsMCwwXSl7CiAgICAgICAgZGlmZmVyZW5jZSgpewogICAgICAgICAgICBjdWJlKFt3aWR0aCtCYXNlX1RoaWNrbmVzcywgQm94X0hlaWdodCwgd2FsbFRoaWNrbmVzc10sIGNlbnRlcj10cnVlKTsKICAgICAgICAgICAgdGhyZWFkZWRSb2RGb3JIb2xlKGxlbmd0aCA9IHdhbGxUaGlja25lc3MqMiwgY2VudGVyID0gdHJ1ZSwgdG9sZXJhbmNlID0gMC4yLCBob2xlX3JhZGl1cz1UQl9TQ1JFV19UaHJlYWRlZF9Sb2RfRGlhbWV0ZXIvMik7CiAgICAgICAgfQogICAgfQp9Cgptb2R1bGUgYm94U2lkZUZsYXQod2FsbFRoaWNrbmVzcz0yLCBzaWRlPTEpewogICAgd2lkdGggPSAoc2lkZSA9PSAxIHx8IHNpZGUgPT0gMykgPyBCb3hfV2lkdGhfWCA6IEJveF9XaWR0aF9ZOwogICAgcm90YXRlKFs5MCwwLDBdKXsKICAgICAgICBjdWJlKFt3aWR0aCtCYXNlX1RoaWNrbmVzcywgQm94X0hlaWdodCwgd2FsbFRoaWNrbmVzc10sIGNlbnRlcj10cnVlKTsKICAgIH0KfQoKbW9kdWxlIGJveFNpZGVXaXJlQ2xpcE5UeXBlKHdhbGxUaGlja25lc3M9Miwgc2lkZT0xKXsKICAgIHdpZHRoID0gKHNpZGUgPT0gMSB8fCBzaWRlID09IDMpID8gQm94X1dpZHRoX1ggOiBCb3hfV2lkdGhfWTsKICAgIHJvdGF0ZShbOTAsMCwwXSl7CiAgICAgICAgY3ViZShbd2lkdGgrQmFzZV9UaGlja25lc3MsIEJveF9IZWlnaHQsIHdhbGxUaGlja25lc3NdLCBjZW50ZXI9dHJ1ZSk7CiAgICAgICAgdHJhbnNsYXRlKFt3aWR0aCoxLzUsIDAsIDBdKXsKICAgICAgICAgICAgcm90YXRlKFswLDAsMF0pewogICAgICAgICAgICAgICAgd2lyZUNsaXBBcm1OKHdhbGxUaGlja25lc3MpOwogICAgICAgICAgICB9CiAgICAgICAgfQogICAgICAgIHRyYW5zbGF0ZShbLXdpZHRoKjEvNSwgQm94X0hlaWdodC8yLCAwXSl7CiAgICAgICAgICAgIHJvdGF0ZShbMCwwLDE4MF0pewogICAgICAgICAgICAgICAgd2lyZUNsaXBBcm1OKHdhbGxUaGlja25lc3MpOwogICAgICAgICAgICB9CiAgICAgICAgfQogICAgfQoKfQoKbW9kdWxlIHdpcmVDbGlwQXJtTih3YWxsVGhpY2tuZXNzPTIsIGFybVdpZHRoPTcsIG9wZW5pbmdXaWR0aD03LCBhcm1UaGlja25lc3M9NSl7CiAgICBvcGVuV2lkdGg9b3BlbmluZ1dpZHRoOwogICAgdGhpY2tuZXNzPWFybVRoaWNrbmVzczsKICAgIG9wZW5XaWR0aE91dGVyPW9wZW5XaWR0aCt0aGlja25lc3MqNS8xMDsKICAgIGxpcEhlaWdodD03OwogICAgdG90YWxJbm5lckhlaWdodD0xNDsKICAgIGVsYm93SGVpZ2h0PWxpcEhlaWdodCt0aGlja25lc3MqNS8xMDsKICAgIHRvcG1vc3RIZWlnaHQ9dG90YWxJbm5lckhlaWdodCt0aGlja25lc3M7CgogICAgcG9pbnRBcnJheSA9IFsKICAgICAgICBbb3BlbldpZHRoLDBdLAogICAgICAgIFtvcGVuV2lkdGhPdXRlciwwXSwKICAgICAgICBbb3BlbldpZHRoT3V0ZXIsIGVsYm93SGVpZ2h0XSwKICAgICAgICBbMCx0b3Btb3N0SGVpZ2h0XSwKICAgICAgICBbMCx0b3RhbElubmVySGVpZ2h0XSwKICAgICAgICBbb3BlbldpZHRoLGxpcEhlaWdodF0sCiAgICAgICAgW29wZW5XaWR0aCwwXQogICAgXTsKICAgIHRyYW5zbGF0ZShbMCwtMSp0aGlja25lc3MqNi8xMCx3YWxsVGhpY2tuZXNzLzJdKSByb3RhdGUoWzAsLTkwLDBdKXsKICAgICAgICBsaW5lYXJfZXh0cnVkZShoZWlnaHQ9YXJtV2lkdGgsIGNlbnRlcj10cnVlKXsKICAgICAgICAgICAgcG9seWdvbihwb2ludHM9cG9pbnRBcnJheSk7CiAgICAgICAgfQogICAgfQogICAgCn0KCm1vZHVsZSBib3hTaWRlU2ltcGxlSG9vayh3YWxsVGhpY2tuZXNzPTIsIGFybVdpZHRoPTcsIG9wZW5pbmdXaWR0aD03LCBhcm1UaGlja25lc3M9NSwgc2lkZT0xKXsKICAgIHdpZHRoID0gKHNpZGUgPT0gMSB8fCBzaWRlID09IDMpID8gQm94X1dpZHRoX1ggOiBCb3hfV2lkdGhfWTsKICAgIHJvdGF0ZShbOTAsMCwwXSl7CiAgICAgICAgY3ViZShbd2lkdGgrQmFzZV9UaGlja25lc3MsIEJveF9IZWlnaHQsIHdhbGxUaGlja25lc3NdLCBjZW50ZXI9dHJ1ZSk7CiAgICAgICAgdHJhbnNsYXRlKFswLCAwLCAwXSl7CiAgICAgICAgICAgIHJvdGF0ZShbMCwwLDBdKXsKICAgICAgICAgICAgICAgIHdpcmVDbGlwQXJtTih3YWxsVGhpY2tuZXNzKTsKICAgICAgICAgICAgfQogICAgICAgIH0KICAgIH0KCn0KCgptb2R1bGUgYm94U2lkZVdpcmVDbGlwV1R5cGUod2FsbFRoaWNrbmVzcz0yLCBjaGFubmVsV2lkdGg9MTUsIHdpZHRoPTI1LCBkZXB0aD0xNywgaGVpZ2h0PUJveF9IZWlnaHQsIHNpZGU9MSl7CiAgICB3aWR0aCA9IChzaWRlID09IDEgfHwgc2lkZSA9PSAzKSA/IEJveF9XaWR0aF9YIDogQm94X1dpZHRoX1k7CiAgICB3QnJhY2VXaWR0aCA9IDI1OwogICAgcG9pbnRBcnJheUVuZCA9IFsKICAgICAgICBbMCwwXSwKICAgICAgICBbZGVwdGgsMF0sCiAgICAgICAgW2RlcHRoLCBoZWlnaHRdLAogICAgICAgIFtkZXB0aC01LCBoZWlnaHRdLAogICAgICAgIFtkZXB0aC01LCBoZWlnaHQqMi8zXSwKICAgICAgICBbZGVwdGgtNSwgaGVpZ2h0KjEvM10sCiAgICAgICAgWzUsIGhlaWdodCoxLzNdLAogICAgICAgIFs1LGhlaWdodF0sCiAgICAgICAgWzAsaGVpZ2h0XSwKICAgICAgICBbMCwwXQogICAgXTsKICAgIHBvaW50QXJyYXlNaWQgPSBbCiAgICAgICAgWzUsIDBdLAogICAgICAgIFtkZXB0aCwwXSwKICAgICAgICBbZGVwdGgsIGhlaWdodF0sCiAgICAgICAgW2RlcHRoLTEwLCBoZWlnaHRdLAogICAgICAgIFtkZXB0aC0xMCwgaGVpZ2h0KjIvMytoZWlnaHQqMi82XSwKICAgICAgICBbZGVwdGgtNSwgaGVpZ2h0KjIvM10sCiAgICAgICAgW2RlcHRoLTUsIGhlaWdodCoxLzNdLAogICAgICAgIFs1LCBoZWlnaHQqMS8zXSwKICAgICAgICBbNSwgMF0sCiAgICBdOwoKICAgIHJvdGF0ZShbOTAsMCwwXSl7CiAgICAgICAgdW5pb24oKXsKICAgICAgICAgICAgY3ViZShbd2lkdGgrQmFzZV9UaGlja25lc3MsIEJveF9IZWlnaHQsIHdhbGxUaGlja25lc3NdLCBjZW50ZXI9dHJ1ZSk7CiAgICAgICAgICAgIHRyYW5zbGF0ZShbLXdCcmFjZVdpZHRoLzMsQm94X0hlaWdodC8yLHdhbGxUaGlja25lc3MvMl0pIHJvdGF0ZShbMCwtOTAsMTgwXSl7CiAgICAgICAgICAgICAgICBsaW5lYXJfZXh0cnVkZShoZWlnaHQ9d0JyYWNlV2lkdGgvMywgY2VudGVyPXRydWUpewogICAgICAgICAgICAgICAgICAgIHBvbHlnb24ocG9pbnRzPXBvaW50QXJyYXlFbmQpOwogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgICAgIAogICAgICAgICAgICB0cmFuc2xhdGUoWzAsQm94X0hlaWdodC8yLHdhbGxUaGlja25lc3MvMl0pIHJvdGF0ZShbMCwtOTAsMTgwXSl7CiAgICAgICAgICAgICAgICBkaWZmZXJlbmNlKCl7CiAgICAgICAgICAgICAgICAgICAgbGluZWFyX2V4dHJ1ZGUoaGVpZ2h0PXdCcmFjZVdpZHRoLzMsIGNlbnRlcj10cnVlKXsKICAgICAgICAgICAgICAgICAgICAgICAgcG9seWdvbihwb2ludHM9cG9pbnRBcnJheU1pZCk7CiAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgIHRyYW5zbGF0ZShbZGVwdGgqMi8zKjYvMTAsMTAsd0JyYWNlV2lkdGgvMyo1LzhdKSByb3RhdGUoWy05MCwtMCwwXSl7CiAgICAgICAgICAgICAgICAgICAgICAgIGN5bGluZGVyKHI9NCwgaD1oZWlnaHQpOwogICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICB0cmFuc2xhdGUoW2RlcHRoKjIvMyo2LzEwLDEwLC13QnJhY2VXaWR0aC8zKjUvOF0pIHJvdGF0ZShbLTkwLC0wLDBdKXsKICAgICAgICAgICAgICAgICAgICAgICAgY3lsaW5kZXIocj00LCBoPWhlaWdodCk7CiAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgfQoKICAgICAgICAgICAgfQogICAgICAgICAgICB0cmFuc2xhdGUoW3dCcmFjZVdpZHRoLzMsQm94X0hlaWdodC8yLHdhbGxUaGlja25lc3MvMl0pIHJvdGF0ZShbMCwtOTAsMTgwXSl7CiAgICAgICAgICAgICAgICBsaW5lYXJfZXh0cnVkZShoZWlnaHQ9d0JyYWNlV2lkdGgvMywgY2VudGVyPXRydWUpewogICAgICAgICAgICAgICAgICAgIHBvbHlnb24ocG9pbnRzPXBvaW50QXJyYXlFbmQpOwogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgCiAgICAgICAgfQogICAgfQp9ICAgCiAgICAKbW9kdWxlIGJveFNpZGVTbGlkZUxvY2tTbG90KHdhbGxUaGlja25lc3M9Miwgc2xvdFdpZHRoTGFyZ2U9U2xvdF9DaGFubmVsX1dpZHRoX0xhcmdlX0VuZCwgc2xvdFdpZHRoU21hbGw9U2xvdF9DaGFubmVsX1dpZHRoX1NtYWxsX0VuZCwgc2xvdERlcHRoPVNsb3RfRGVwdGgsIHNsb3RIZWlnaHQ9Qm94X0hlaWdodCwgc2lkZT0xKXsKICAgIHdpZHRoID0gKHNpZGUgPT0gMSB8fCBzaWRlID09IDMpID8gQm94X1dpZHRoX1ggOiBCb3hfV2lkdGhfWTsKICAgIHBvaW50QXJyYXlXb3JraW5nT3JpZ2luYWw9WwogICAgICAgIFtzbG90RGVwdGgvdGFuKDQ1KSwwXSwKICAgICAgICBbMCwgc2xvdERlcHRoXSwKICAgICAgICBbc2xvdFdpZHRoTGFyZ2UsIHNsb3REZXB0aF0sCiAgICAgICAgW3Nsb3RXaWR0aExhcmdlLXNsb3REZXB0aC90YW4oNDUpLDBdLAogICAgICAgIFswLDBdCiAgICBdOwoKICAgIHBvaW50QXJyYXlNdWx0aUNvbm5lY3RDb21wYXRpYmxlPVsKICAgICAgICBbKHNsb3RXaWR0aExhcmdlLXNsb3RXaWR0aFNtYWxsKS8yLDBdLAogICAgICAgIFsxLCBzbG90RGVwdGgtMV0sCiAgICAgICAgWzEsIHNsb3REZXB0aF0sCiAgICAgICAgW3Nsb3RXaWR0aExhcmdlLTAuNSwgc2xvdERlcHRoXSwKICAgICAgICBbc2xvdFdpZHRoTGFyZ2UtMC41LCBzbG90RGVwdGgtMV0sCiAgICAgICAgWyhzbG90V2lkdGhMYXJnZS1zbG90V2lkdGhTbWFsbCkvMitzbG90V2lkdGhTbWFsbCwwXSwKICAgICAgICBbMCwwXQogICAgXTsKCiAgICByb3RhdGUoWzkwLDAsMF0pewogICAgICAgIGN1YmUoW3dpZHRoK0Jhc2VfVGhpY2tuZXNzLCBCb3hfSGVpZ2h0LCB3YWxsVGhpY2tuZXNzXSwgY2VudGVyPXRydWUpOwogICAgICAgIHRyYW5zbGF0ZShbLXNsb3RXaWR0aExhcmdlLzIsIDAsIHdhbGxUaGlja25lc3MvMl0pewogICAgICAgICAgICByb3RhdGUoWzkwLDAsMF0pewogICAgICAgICAgICAgICAgbGluZWFyX2V4dHJ1ZGUoaGVpZ2h0PXNsb3RIZWlnaHQsIGNlbnRlcj10cnVlKXsKICAgICAgICAgICAgICAgICAgICBwb2x5Z29uKHBvaW50cz1wb2ludEFycmF5TXVsdGlDb25uZWN0Q29tcGF0aWJsZSk7CiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgIH0gICAKICAgICAgICB9CiAgICB9Cgp9CiAgICAKICAgIAptb2R1bGUgYm94U2lkZVBvc3RDbGlwKHdhbGxUaGlja25lc3M9MiwgZ2VuZXJhdGVGYXN0ZW5lcj10cnVlLCBnZW5lcmF0ZVNpZGVDbGlwPXRydWUsIHNpZGU9MSl7CiAgICB3aWR0aCA9IChzaWRlID09IDEgfHwgc2lkZSA9PSAzKSA/IEJveF9XaWR0aF9YIDogQm94X1dpZHRoX1k7CiAgICAKICAgIGNsaXBQb3J0aW9uT2ZXaWR0aCA9IDMvMTY7CiAgICBjbGlwTGlwTGVuZ3RoID0gKHdpZHRoK0Jhc2VfVGhpY2tuZXNzKSpjbGlwUG9ydGlvbk9mV2lkdGg7CiAgICBjbGlwTGlwVGhpY2tuZXNzID0gd2FsbFRoaWNrbmVzczsKICAgIGNsaXBDb25uZWN0b3JJbm5lckxlbmd0aCA9IChjbGlwTGlwTGVuZ3RoLzIpOwogICAgY2xpcExpcElubmVySGVpZ2h0ID0gd2FsbFRoaWNrbmVzcyoyOwogICAgY2xpcEJhc2VUaGlja25lc3MgPSAyOwoKICAgIGNvbm5lY3RvclRvbGVyYW5jZSA9IDAuMTsKCiAgICBjb29yZHNMZWZ0U3RhcnRYID0gMC13YWxsVGhpY2tuZXNzLzI7CiAgICBjb29yZHNSaWdodFN0YXJ0WCA9IHdpZHRoK3dhbGxUaGlja25lc3MvMjsKCiAgICBmYXN0ZW5lckNvb3Jkc0xlZnRTdGFydFggPSAwLXdhbGxUaGlja25lc3MvMi1jbGlwTGlwVGhpY2tuZXNzOwogICAgZmFzdGVuZXJDb29yZHNSaWdodFN0YXJ0WCA9IHdpZHRoK3dhbGxUaGlja25lc3MvMitjbGlwTGlwVGhpY2tuZXNzOwoKICAgIAoKCgoKCgogICAgY29vcmRzTGVmdD1bCiAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFgsMF0sCiAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFgrY2xpcExpcExlbmd0aCwgMF0sCiAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFgrY2xpcExpcExlbmd0aCwgY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3MqMl0sCiAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFgrY2xpcExpcExlbmd0aC1jbGlwQ29ubmVjdG9ySW5uZXJMZW5ndGgtY2xpcExpcFRoaWNrbmVzcywgY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3MqMl0sCiAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFgrY2xpcExpcExlbmd0aC1jbGlwQ29ubmVjdG9ySW5uZXJMZW5ndGgtY2xpcExpcFRoaWNrbmVzcywgY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3NdLAogICAgICAgIFtjb29yZHNMZWZ0U3RhcnRYK2NsaXBMaXBMZW5ndGgtY2xpcExpcFRoaWNrbmVzcywgY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3NdLAogICAgICAgIFtjb29yZHNMZWZ0U3RhcnRYK2NsaXBMaXBMZW5ndGgtY2xpcExpcFRoaWNrbmVzcywgY2xpcExpcFRoaWNrbmVzc10sCiAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFgsIGNsaXBMaXBUaGlja25lc3NdLAogICAgICAgIFtjb29yZHNMZWZ0U3RhcnRYLCAwXQogICAgXTsKICAgCgogICBjb29yZHNSaWdodD1bCiAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYLCAwXSwKICAgICAgICBbY29vcmRzUmlnaHRTdGFydFggLSBjbGlwTGlwTGVuZ3RoLCAwXSwKICAgICAgICBbY29vcmRzUmlnaHRTdGFydFgtY2xpcExpcExlbmd0aCwgY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3MqMl0sCiAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYLWNsaXBMaXBMZW5ndGgrY2xpcENvbm5lY3RvcklubmVyTGVuZ3RoK2NsaXBMaXBUaGlja25lc3MsIGNsaXBMaXBJbm5lckhlaWdodCtjbGlwTGlwVGhpY2tuZXNzKjJdLAogICAgICAgIFtjb29yZHNSaWdodFN0YXJ0WC1jbGlwTGlwTGVuZ3RoK2NsaXBDb25uZWN0b3JJbm5lckxlbmd0aCtjbGlwTGlwVGhpY2tuZXNzLCBjbGlwTGlwSW5uZXJIZWlnaHQrY2xpcExpcFRoaWNrbmVzc10sCiAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYLWNsaXBMaXBMZW5ndGgrY2xpcExpcFRoaWNrbmVzcywgY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3NdLAogICAgICAgIFtjb29yZHNSaWdodFN0YXJ0WC1jbGlwTGlwTGVuZ3RoK2NsaXBMaXBUaGlja25lc3MsIGNsaXBMaXBUaGlja25lc3NdLAogICAgICAgIFtjb29yZHNSaWdodFN0YXJ0WCwgY2xpcExpcFRoaWNrbmVzc10sCiAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYLCAwXQogICAgXTsKCiAgICBjb29yZHNDb25uZWN0b3JkZWxtZSA9IFsKICAgICAgICBbY29vcmRzTGVmdFN0YXJ0WCwgY2xpcExpcFRoaWNrbmVzcytjb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0MQogICAgICAgIFtjb29yZHNMZWZ0U3RhcnRYICsgY2xpcExpcExlbmd0aCAtIGNsaXBMaXBUaGlja25lc3MgLSBjb25uZWN0b3JUb2xlcmFuY2UsIGNsaXBMaXBUaGlja25lc3MrY29ubmVjdG9yVG9sZXJhbmNlXSwgLy9wdDIKICAgICAgICBbY29vcmRzTGVmdFN0YXJ0WCArIGNsaXBMaXBMZW5ndGggLSBjbGlwTGlwVGhpY2tuZXNzIC0gY29ubmVjdG9yVG9sZXJhbmNlLCBjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBJbm5lckhlaWdodC1jb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0MwogICAgICAgIFtjb29yZHNMZWZ0U3RhcnRYICsgY2xpcExpcExlbmd0aCAtIGNsaXBMaXBUaGlja25lc3MgLSBjb25uZWN0b3JUb2xlcmFuY2UgLSBjbGlwQ29ubmVjdG9ySW5uZXJMZW5ndGgsIGNsaXBMaXBUaGlja25lc3MrY2xpcExpcElubmVySGVpZ2h0LWNvbm5lY3RvclRvbGVyYW5jZV0sIC8vcHQ0CiAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFggKyBjbGlwTGlwTGVuZ3RoIC0gY2xpcExpcFRoaWNrbmVzcyAtIGNvbm5lY3RvclRvbGVyYW5jZSAtIGNsaXBDb25uZWN0b3JJbm5lckxlbmd0aCwgY2xpcExpcFRoaWNrbmVzcytjbGlwTGlwSW5uZXJIZWlnaHQrY2xpcExpcFRoaWNrbmVzcytjb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0NQogICAgICAgIFtjb29yZHNSaWdodFN0YXJ0WCAtIGNsaXBMaXBMZW5ndGgrY2xpcENvbm5lY3RvcklubmVyTGVuZ3RoK2NsaXBMaXBUaGlja25lc3MrY29ubmVjdG9yVG9sZXJhbmNlLCBjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBJbm5lckhlaWdodCtjbGlwTGlwVGhpY2tuZXNzK2Nvbm5lY3RvclRvbGVyYW5jZV0sIC8vcHQ2CiAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYIC0gY2xpcExpcExlbmd0aCtjbGlwQ29ubmVjdG9ySW5uZXJMZW5ndGgrY2xpcExpcFRoaWNrbmVzcytjb25uZWN0b3JUb2xlcmFuY2UsIGNsaXBMaXBUaGlja25lc3MrY2xpcExpcElubmVySGVpZ2h0LWNvbm5lY3RvclRvbGVyYW5jZV0sIC8vcHQ3CiAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYIC0gY2xpcExpcExlbmd0aCArIGNsaXBMaXBUaGlja25lc3MgKyBjb25uZWN0b3JUb2xlcmFuY2UsIGNsaXBMaXBUaGlja25lc3MrY2xpcExpcElubmVySGVpZ2h0LWNvbm5lY3RvclRvbGVyYW5jZV0sIC8vcHQ4CiAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYIC0gY2xpcExpcExlbmd0aCArIGNsaXBMaXBUaGlja25lc3MgKyBjb25uZWN0b3JUb2xlcmFuY2UsIGNsaXBMaXBUaGlja25lc3MrY29ubmVjdG9yVG9sZXJhbmNlXSwgLy9wdDkKICAgICAgICAvLyBbY29vcmRzUmlnaHRTdGFydFggLSBjbGlwTGlwTGVuZ3RoICsgY2xpcExpcFRoaWNrbmVzcyArIGNsaXBDb25uZWN0b3JJbm5lckxlbmd0aCArIGNvbm5lY3RvclRvbGVyYW5jZSwgY2xpcExpcFRoaWNrbmVzcytjbGlwTGlwSW5uZXJIZWlnaHQtY29ubmVjdG9yVG9sZXJhbmNlXSwKICAgICAgICBbY29vcmRzUmlnaHRTdGFydFgsIGNsaXBMaXBUaGlja25lc3MrY29ubmVjdG9yVG9sZXJhbmNlXSwgLy9wdDEwCiAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYLCBjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBJbm5lckhlaWdodCtjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBUaGlja25lc3NdLCAvL3B0MTEKICAgICAgICAvLyBbY29vcmRzUmlnaHRTdGFydFgsIGNsaXBMaXBUaGlja25lc3MrY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3MrY2xpcExpcFRoaWNrbmVzc10sCiAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFgsIGNsaXBMaXBUaGlja25lc3MrY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3MrY2xpcExpcFRoaWNrbmVzc10sIC8vcHQxMgoKICAgICAgICBbY29vcmRzTGVmdFN0YXJ0WCwgY2xpcExpcFRoaWNrbmVzcytjb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0MTMKICAgIF07CgogICAgY29vcmRzRmFzdGVuZXIgPSBbCiAgICAgICAgW2Zhc3RlbmVyQ29vcmRzTGVmdFN0YXJ0WCwgY2xpcExpcFRoaWNrbmVzcytjb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0MQogICAgICAgIFtmYXN0ZW5lckNvb3Jkc0xlZnRTdGFydFggKyBjbGlwTGlwTGVuZ3RoIC0gY2xpcExpcFRoaWNrbmVzcyArIGNsaXBMaXBUaGlja25lc3MgLSBjb25uZWN0b3JUb2xlcmFuY2UsIGNsaXBMaXBUaGlja25lc3MrY29ubmVjdG9yVG9sZXJhbmNlXSwgLy9wdDIKICAgICAgICBbZmFzdGVuZXJDb29yZHNMZWZ0U3RhcnRYICsgY2xpcExpcExlbmd0aCAtIGNsaXBMaXBUaGlja25lc3MgKyBjbGlwTGlwVGhpY2tuZXNzIC0gY29ubmVjdG9yVG9sZXJhbmNlLCBjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBJbm5lckhlaWdodC1jb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0MwogICAgICAgIFtmYXN0ZW5lckNvb3Jkc0xlZnRTdGFydFggKyBjbGlwTGlwTGVuZ3RoIC0gY2xpcExpcFRoaWNrbmVzcyAgKyBjbGlwTGlwVGhpY2tuZXNzIC0gY29ubmVjdG9yVG9sZXJhbmNlIC0gY2xpcENvbm5lY3RvcklubmVyTGVuZ3RoLCBjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBJbm5lckhlaWdodC1jb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0NAogICAgICAgIFtmYXN0ZW5lckNvb3Jkc0xlZnRTdGFydFggKyBjbGlwTGlwTGVuZ3RoIC0gY2xpcExpcFRoaWNrbmVzcyAgKyBjbGlwTGlwVGhpY2tuZXNzLSBjb25uZWN0b3JUb2xlcmFuY2UgLSBjbGlwQ29ubmVjdG9ySW5uZXJMZW5ndGgsIGNsaXBMaXBUaGlja25lc3MrY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3MrY29ubmVjdG9yVG9sZXJhbmNlXSwgLy9wdDUKICAgICAgICBbZmFzdGVuZXJDb29yZHNSaWdodFN0YXJ0WCAtIGNsaXBMaXBMZW5ndGgrY2xpcENvbm5lY3RvcklubmVyTGVuZ3RoK2NsaXBMaXBUaGlja25lc3MgLSBjbGlwTGlwVGhpY2tuZXNzK2Nvbm5lY3RvclRvbGVyYW5jZSwgY2xpcExpcFRoaWNrbmVzcytjbGlwTGlwSW5uZXJIZWlnaHQrY2xpcExpcFRoaWNrbmVzcytjb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0NgogICAgICAgIFtmYXN0ZW5lckNvb3Jkc1JpZ2h0U3RhcnRYIC0gY2xpcExpcExlbmd0aCtjbGlwQ29ubmVjdG9ySW5uZXJMZW5ndGgrY2xpcExpcFRoaWNrbmVzcyAtY2xpcExpcFRoaWNrbmVzcyArY29ubmVjdG9yVG9sZXJhbmNlLCBjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBJbm5lckhlaWdodC1jb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0NwogICAgICAgIFtmYXN0ZW5lckNvb3Jkc1JpZ2h0U3RhcnRYIC0gY2xpcExpcExlbmd0aCArIGNsaXBMaXBUaGlja25lc3MgLSBjbGlwTGlwVGhpY2tuZXNzICsgY29ubmVjdG9yVG9sZXJhbmNlLCBjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBJbm5lckhlaWdodC1jb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0OAogICAgICAgIFtmYXN0ZW5lckNvb3Jkc1JpZ2h0U3RhcnRYIC0gY2xpcExpcExlbmd0aCArIGNsaXBMaXBUaGlja25lc3MgLSBjbGlwTGlwVGhpY2tuZXNzICsgY29ubmVjdG9yVG9sZXJhbmNlLCBjbGlwTGlwVGhpY2tuZXNzK2Nvbm5lY3RvclRvbGVyYW5jZV0sIC8vcHQ5CiAgICAgICAgLy8gW2Zhc3RlbmVyQ29vcmRzUmlnaHRTdGFydFggLSBjbGlwTGlwTGVuZ3RoICsgY2xpcExpcFRoaWNrbmVzcyArIGNsaXBDb25uZWN0b3JJbm5lckxlbmd0aCArIGNvbm5lY3RvclRvbGVyYW5jZSwgY2xpcExpcFRoaWNrbmVzcytjbGlwTGlwSW5uZXJIZWlnaHQtY29ubmVjdG9yVG9sZXJhbmNlXSwKICAgICAgICBbZmFzdGVuZXJDb29yZHNSaWdodFN0YXJ0WCwgY2xpcExpcFRoaWNrbmVzcytjb25uZWN0b3JUb2xlcmFuY2VdLCAvL3B0MTAKICAgICAgICBbZmFzdGVuZXJDb29yZHNSaWdodFN0YXJ0WCwgY2xpcExpcFRoaWNrbmVzcytjbGlwTGlwSW5uZXJIZWlnaHQrY2xpcExpcFRoaWNrbmVzcytjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBUaGlja25lc3NdLCAvL3B0MTEKICAgICAgICAvLyBbZmFzdGVuZXJDb29yZHNSaWdodFN0YXJ0WCwgY2xpcExpcFRoaWNrbmVzcytjbGlwTGlwSW5uZXJIZWlnaHQrY2xpcExpcFRoaWNrbmVzcytjbGlwTGlwVGhpY2tuZXNzXSwKICAgICAgICBbZmFzdGVuZXJDb29yZHNMZWZ0U3RhcnRYLCBjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBJbm5lckhlaWdodCtjbGlwTGlwVGhpY2tuZXNzK2NsaXBMaXBUaGlja25lc3MrY2xpcExpcFRoaWNrbmVzc10sIC8vcHQxMgogICAgICAgIFtmYXN0ZW5lckNvb3Jkc0xlZnRTdGFydFgsIGNsaXBMaXBUaGlja25lc3MrY29ubmVjdG9yVG9sZXJhbmNlXSwgLy9wdDEzCiAgICBdOwoKICAgIHRyYW5zbGF0ZShbLXdpZHRoLzIsIDAsIDBdKXsKICAgICAgICByb3RhdGUoWzE4MCwgMCwgMF0pewogICAgICAgICAgICBpZihnZW5lcmF0ZVNpZGVDbGlwKXsKICAgICAgICAgICAgICAgIGxpbmVhcl9leHRydWRlKGhlaWdodD1Cb3hfSGVpZ2h0LCBjZW50ZXI9dHJ1ZSl7CiAgICAgICAgICAgICAgICAgICAgcG9seWdvbihwb2ludHM9Y29vcmRzTGVmdCk7CiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICB0cmFuc2xhdGUoWzAsIDAsIC1Cb3hfSGVpZ2h0LzIrd2FsbFRoaWNrbmVzcy8yXSl7CiAgICAgICAgICAgICAgICAgICAgbGluZWFyX2V4dHJ1ZGUoaGVpZ2h0PWNsaXBCYXNlVGhpY2tuZXNzLCBjZW50ZXI9dHJ1ZSl7CiAgICAgICAgICAgICAgICAgICAgICAgIHBvbHlnb24ocG9pbnRzPVsKICAgICAgICAgICAgICAgICAgICAgICAgICAgIFtjb29yZHNMZWZ0U3RhcnRYLCAwXSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgIFtjb29yZHNMZWZ0U3RhcnRYK2NsaXBMaXBMZW5ndGgsIDBdLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgW2Nvb3Jkc0xlZnRTdGFydFgrY2xpcExpcExlbmd0aCwgY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3MqMl0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBbY29vcmRzTGVmdFN0YXJ0WCwgY2xpcExpcElubmVySGVpZ2h0K2NsaXBMaXBUaGlja25lc3MqMl0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBbY29vcmRzTGVmdFN0YXJ0WCwgMF0KICAgICAgICAgICAgICAgICAgICAgICAgXSk7CiAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgIGxpbmVhcl9leHRydWRlKGhlaWdodD1Cb3hfSGVpZ2h0LCBjZW50ZXI9dHJ1ZSl7CiAgICAgICAgICAgICAgICAgICAgcG9seWdvbihwb2ludHM9Y29vcmRzUmlnaHQpOwogICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgdHJhbnNsYXRlKFswLCAwLCAtQm94X0hlaWdodC8yK3dhbGxUaGlja25lc3MvMl0pewogICAgICAgICAgICAgICAgICAgIGxpbmVhcl9leHRydWRlKGhlaWdodD1jbGlwQmFzZVRoaWNrbmVzcywgY2VudGVyPXRydWUpewogICAgICAgICAgICAgICAgICAgICAgICBwb2x5Z29uKHBvaW50cz1bCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBbY29vcmRzUmlnaHRTdGFydFgsIDBdLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYLWNsaXBMaXBMZW5ndGgsIDBdLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYLWNsaXBMaXBMZW5ndGgsIGNsaXBMaXBJbm5lckhlaWdodCtjbGlwTGlwVGhpY2tuZXNzKjJdLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgW2Nvb3Jkc1JpZ2h0U3RhcnRYLCBjbGlwTGlwSW5uZXJIZWlnaHQrY2xpcExpcFRoaWNrbmVzcyoyXSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgIFtjb29yZHNSaWdodFN0YXJ0WCwgMF0KICAgICAgICAgICAgICAgICAgICAgICAgXSk7CiAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgICAgIGlmKGdlbmVyYXRlRmFzdGVuZXIpewogICAgICAgICAgICAgICAgdHJhbnNsYXRlKFswLCB3aWR0aCwgd2FsbFRoaWNrbmVzcy8yK2Nvbm5lY3RvclRvbGVyYW5jZV0pewogICAgICAgICAgICAgICAgICAgIGNvbG9yKCJ5ZWxsb3ciKSAKICAgICAgICAgICAgICAgICAgICBkaWZmZXJlbmNlKCl7CiAgICAgICAgICAgICAgICAgICAgICAgIGxpbmVhcl9leHRydWRlKGhlaWdodD1Cb3hfSGVpZ2h0LWNsaXBCYXNlVGhpY2tuZXNzLCBjZW50ZXI9dHJ1ZSl7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICBwb2x5Z29uKHBvaW50cz1jb29yZHNGYXN0ZW5lcik7CiAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgdHJhbnNsYXRlKFt3aWR0aC8yLCAwLCAwXSkgewogICAgICAgICAgICAgICAgICAgICAgICAgICAgcm90YXRlKFs5MCwgOTAsIDBdKXsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB0aHJlYWRlZFJvZEZvckhvbGUobGVuZ3RoID0gd2FsbFRoaWNrbmVzcyoyMCwgY2VudGVyID0gdHJ1ZSwgdG9sZXJhbmNlID0gMC4yLCBob2xlX3JhZGl1cz1UQl9TQ1JFV19UaHJlYWRlZF9Sb2RfRGlhbWV0ZXIvMik7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgICAgIAogICAgICAgIH0KICAgIH0KICAgIAoKICAgIHJvdGF0ZShbOTAsMCwwXSl7CiAgICAgICAgLy8gdHJhbnNsYXRlKFsod2lkdGgrQmFzZV9UaGlja25lc3MpLzIgLSAod2lkdGgrQmFzZV9UaGlja25lc3MpKmNsaXBQb3J0aW9uT2ZXaWR0aC8yLCAwLCAwXSl7CiAgICAgICAgLy8gICAgIGNvbG9yKCJwdXJwbGUiKSBjdWJlKFtjbGlwTGlwTGVuZ3RoLCBCb3hfSGVpZ2h0LCB3YWxsVGhpY2tuZXNzXSwgY2VudGVyPXRydWUpOwogICAgICAgIC8vIH0KICAgICAgICAKICAgICAgICAKICAgICAgICAKICAgIH0KCn0=")
        logInfo("Loading /Electric Fence Post Mount.scad (" + data.length + " bytes)")
        const parent = "/Electric Fence Post Mount.scad".substring(0, "/Electric Fence Post Mount.scad".lastIndexOf("/"))
        if (parent) {
            instance.FS.mkdirTree(parent)
        }
        instance.FS.writeFile("/Electric Fence Post Mount.scad", data)
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