#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Generate Temple Fans
#
# Renders Small / Medium / Large versions of a temple hand fan from the generator
# named in the config's scad_file.  Each run gets a folder of its own, and every
# size in it writes the config's default_outputs:
#
#   Hand Fan - {Temple} Temple/
#     Hand Fan - {Temple} Temple - {Size}.stl                printing layout, all blades
#     Hand Fan - {Temple} Temple - {Size}.3mf                same layout, colors preserved
#     Hand Fan - {Temple} Temple - {Size} - Colored.3mf      same layout, etched black
#     Hand Fan - {Temple} Temple - {Size} - Assembled.3mf    the fan as assembled, etched black
#
# A .png of that assembled fan is available too - ask for it with --resulting-files,
# or put "png" back in default_outputs.
#
# The parameters, sizes, output folder and image camera all live in the sidecar
# config "Generate Temple Fans.json" - see the "_comment" block in there.
#
#   ./Generate\ Temple\ Fans.sh                         # asks for everything
#   ./Generate\ Temple\ Fans.sh -t "SLC" -f "SLC Temple" -s 140
#   ./Generate\ Temple\ Fans.sh -t "Washington DC" -f "WashingtonDC Temple" --sizes Medium,Large
#
# Existing files in the output folder are overwritten unless --skip-existing.
# -----------------------------------------------------------------------------

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_CONFIG="$SCRIPT_DIR/${SCRIPT_NAME%.sh}.json"
DEFAULT_OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"

# --- pretty output ------------------------------------------------------------

if [ -t 1 ]; then
    C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_RED=$'\033[31m'
    C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_OFF=$'\033[0m'
else
    C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_OFF=""
fi

info()  { printf '%s\n' "$*"; }
step()  { printf '%s==>%s %s%s%s\n' "$C_GREEN" "$C_OFF" "$C_BOLD" "$*" "$C_OFF"; }
note()  { printf '%s    %s%s\n' "$C_DIM" "$*" "$C_OFF"; }
warn()  { printf '%s!!! %s%s\n' "$C_YELLOW" "$*" "$C_OFF" >&2; }
die()   { printf '%serror:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }

usage() {
    cat <<EOF
${C_BOLD}$SCRIPT_NAME${C_OFF} - render Small/Medium/Large temple hand fans (STL + 3MF + preview PNG)

Usage: $SCRIPT_NAME [options]

Fan options (prompted for if omitted):
  -t, --temple NAME      Temple name, e.g. "Salt Lake" or "Washington DC".
                         A trailing "Temple" is dropped; the file name adds it back.
  -f, --svg FILE         SVG file inside the config's svg_directory.
                         ".svg" is appended when no extension is given.
                         A path with a "/" in it is used as-is.
  -s, --scale PERCENT    Blade_Cutout_SVG_Scale, 5-500. Config default is used
                         when omitted and the prompt is accepted empty.

Other options:
      --resulting-files LIST
                         Comma-separated list of what to generate:
                           stl        printing layout, all blades
                           3mf        same layout with the colours kept
                           colored    printing layout, etched black, as a 3MF
                           assembled  the fan as assembled, etched black, as a 3MF
                           png        that assembled fan as a picture
                         Defaults to the config's default_outputs. Overrides it and
                         both --no- flags. e.g. --resulting-files=stl,png
      --sizes LIST       Comma-separated subset of the sizes in the config
                         (default: all of them, in config order).
  -o, --output-dir DIR   Where the per-temple folder is created. Overrides the config.
  -c, --config FILE      Config file (default: ${DEFAULT_CONFIG##*/}).
      --openscad PATH    OpenSCAD binary (default: the macOS app bundle).
      --no-image         Skip the assembly-view PNG.
      --no-models        Skip the STL/3MF, render only the PNG.
      --skip-existing    Leave files that are already there alone.
  -n, --dry-run          Print the OpenSCAD commands without running them.
  -v, --verbose          Stream OpenSCAD's output instead of logging it quietly.
  -h, --help             This text.

Budget about two minutes of rendering per size - an SVG cutout on 15 blades is a lot
of geometry. --sizes and --resulting-files are the way to cut that down while you are
still settling on a scale.
EOF
}

# --- arguments ----------------------------------------------------------------

TEMPLE=""; SVG_INPUT=""; SVG_SCALE=""; SIZES_FILTER=""; RESULTING_FILES=""
CONFIG="$DEFAULT_CONFIG"; OPENSCAD="${OPENSCAD:-$DEFAULT_OPENSCAD}"; OUT_DIR_OVERRIDE=""
DO_IMAGE=1; DO_MODELS=1; SKIP_EXISTING=0; DRY_RUN=0; VERBOSE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --resulting-files=*)
                          RESULTING_FILES="${1#*=}"; shift ;;
        --resulting-files)
                          [ $# -ge 2 ] || die "$1 needs a value"; RESULTING_FILES="$2"; shift 2 ;;
        -t|--temple)      [ $# -ge 2 ] || die "$1 needs a value"; TEMPLE="$2"; shift 2 ;;
        -f|--svg|--svg-file)
                          [ $# -ge 2 ] || die "$1 needs a value"; SVG_INPUT="$2"; shift 2 ;;
        -s|--scale|--svg-scale)
                          [ $# -ge 2 ] || die "$1 needs a value"; SVG_SCALE="$2"; shift 2 ;;
        --sizes)          [ $# -ge 2 ] || die "$1 needs a value"; SIZES_FILTER="$2"; shift 2 ;;
        -o|--output-dir)  [ $# -ge 2 ] || die "$1 needs a value"; OUT_DIR_OVERRIDE="$2"; shift 2 ;;
        -c|--config)      [ $# -ge 2 ] || die "$1 needs a value"; CONFIG="$2"; shift 2 ;;
        --openscad)       [ $# -ge 2 ] || die "$1 needs a value"; OPENSCAD="$2"; shift 2 ;;
        --no-image)       DO_IMAGE=0; shift ;;
        --no-models)      DO_MODELS=0; shift ;;
        --skip-existing)  SKIP_EXISTING=1; shift ;;
        -n|--dry-run)     DRY_RUN=1; shift ;;
        -v|--verbose)     VERBOSE=1; shift ;;
        -h|--help)        usage; exit 0 ;;
        *)                usage >&2; die "unknown option: $1" ;;
    esac
done

[ "$DO_IMAGE" -eq 1 ] || [ "$DO_MODELS" -eq 1 ] || die "--no-image and --no-models together leave nothing to render"

# --- prerequisites ------------------------------------------------------------

command -v jq >/dev/null 2>&1 || die "jq is required (brew install jq)"
[ -f "$CONFIG" ] || die "config not found: $CONFIG"
jq empty "$CONFIG" 2>/dev/null || die "config is not valid JSON: $CONFIG"
[ -x "$OPENSCAD" ] || die "OpenSCAD not executable: $OPENSCAD (use --openscad PATH)"

cfg() { jq -r "$1" "$CONFIG"; }

SCAD_FILE="$(cfg '.scad_file // "Hand Fan Generator v3.scad"')"
case "$SCAD_FILE" in /*) ;; *) SCAD_FILE="$SCRIPT_DIR/$SCAD_FILE" ;; esac
[ -f "$SCAD_FILE" ] || die "generator not found: $SCAD_FILE (check .scad_file in the config)"

SVG_DIR="$(cfg '.svg_directory // "fan svg files"')"
case "$SVG_DIR" in /*) ;; *) SVG_DIR="$SCRIPT_DIR/$SVG_DIR" ;; esac

OUT_DIR="${OUT_DIR_OVERRIDE:-$(cfg '.output_directory // "Temple Fans"')}"
case "$OUT_DIR" in /*) ;; *) OUT_DIR="$SCRIPT_DIR/$OUT_DIR" ;; esac

FOLDER_TEMPLATE="$(cfg '.folder_name_template // "Hand Fan - {temple} Temple"')"
NAME_TEMPLATE="$(cfg '.file_name_template // "Hand Fan - {temple} Temple - {size}"')"
DEFAULT_SCALE="$(cfg '.defaults.svg_scale // 140')"

# What a plain run produces. An older config without this key keeps its old
# behaviour: whatever .models.formats listed, plus the picture.
DEFAULT_OUTPUTS=""
while IFS= read -r o; do
    [ -n "$o" ] && DEFAULT_OUTPUTS="$DEFAULT_OUTPUTS $o"
done <<EOF
$(cfg '(.default_outputs // ((.models.formats // ["stl","3mf"]) + ["png"]))[]')
EOF
[ -n "${DEFAULT_OUTPUTS# }" ] || die "no outputs in the config (.default_outputs)"

# Export settings for every 3MF this script writes, as export-3mf/<key>=<value> pairs.
# They matter: OpenSCAD's CLI does not read the GUI's export preferences, and its
# built-in default writes colours as <basematerials>, which plenty of slicers and
# viewers ignore - the file looks like one flat colour. material-type=color writes a
# colorgroup instead, which is the form they read. Values cannot contain spaces.
THREEMF_OPTS=""
while IFS= read -r kv; do
    [ -n "$kv" ] && THREEMF_OPTS="$THREEMF_OPTS $kv"
done <<EOF
$(cfg '(.export_3mf // {"material-type":"color"}) | to_entries[] | "\(.key)=\(.value)"')
EOF

MODELS_MODE="$(cfg '.models.rendering_mode // "printing"')"
# OpenSCAD still writes ASCII STL by default; an SVG-cut fan is around 180 MB that way
# and about a fifth of that as binstl. Set it to "" in the config for ASCII.
STL_FORMAT="$(cfg '.models.stl_format // "binstl"')"

# Outputs that carry their own rendering mode and parameter overrides, each configured
# by a block of the same name. Both of these keep the etch layer black so the artwork
# shows, and both go out as 3MF because that is the format that carries colour - an STL
# would be one merged solid with the black thrown away.
#
#   assembled - the fan as it ends up in the hand, the view the picture shows
#   colored   - the printing layout, so the file that gets sliced is two-tone too
VARIANT_OUTPUTS="assembled colored"
VARIANTS_JSON='["assembled","colored"]'

# out_cfg <output> <key> <default>
out_cfg() { jq -r --arg o "$1" --arg k "$2" --arg d "$3" '(.[$o][$k] // $d) | tostring' "$CONFIG"; }

IMAGE_MODE="$(cfg '.image.rendering_mode // "assembly"')"
IMG_SIZE="$(cfg '.image.imgsize // "1600,1200"')"
IMG_CAMERA="$(cfg '.image.camera // ""')"
IMG_PROJECTION="$(cfg '.image.projection // ""')"
IMG_COLORSCHEME="$(cfg '.image.colorscheme // ""')"
IMG_VIEWALL="$(cfg '.image.view_all // true')"
IMG_AUTOCENTER="$(cfg '.image.autocenter // true')"
IMG_RENDER="$(cfg '.image.render // true')"

ALL_SIZES=""
while IFS= read -r s; do
    [ -n "$s" ] && ALL_SIZES="$ALL_SIZES
$s"
done <<EOF
$(cfg '.sizes[].name')
EOF
[ -n "$ALL_SIZES" ] || die "no sizes defined in the config (.sizes)"

# --- questions ----------------------------------------------------------------

interactive() { [ -t 0 ] && [ -r /dev/tty ]; }

ask() { # ask <prompt> <default>; answer on stdout
    local prompt="$1" default="${2:-}" reply=""
    # Unattended (cron, pipe, CI): fall back to the default if there is one, and only
    # give up on the questions that have no sensible answer of their own.
    if ! interactive; then
        [ -n "$default" ] || die "no value supplied for \"$prompt\" and no terminal to ask on (see --help)"
        printf '%s' "$default"
        return 0
    fi
    if [ -n "$default" ]; then
        printf '%s [%s]: ' "$prompt" "$default" > /dev/tty
    else
        printf '%s: ' "$prompt" > /dev/tty
    fi
    IFS= read -r reply < /dev/tty || true
    printf '%s' "${reply:-$default}"
}

trim() { printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

if [ -z "$TEMPLE" ]; then
    interactive && step "Temple"
    TEMPLE="$(ask 'Temple name (without the word "Temple")')"
fi
# "Salt Lake Temple" and "Salt Lake" both mean the same fan; the file name template
# supplies the word "Temple" itself, so drop a trailing one to avoid doubling it up.
TEMPLE="$(trim "$(printf '%s' "$TEMPLE" | sed -E 's/[[:space:]]+[Tt][Ee][Mm][Pp][Ll][Ee][[:space:]]*$//')")"
[ -n "$TEMPLE" ] || die "temple name is empty"
case "$TEMPLE" in
    */*|*:*) die "temple name cannot contain / or : - it becomes part of the file name" ;;
esac

list_svgs() {
    if [ -d "$SVG_DIR" ]; then
        ls -1 "$SVG_DIR" 2>/dev/null | grep -i '\.svg$' | sed 's/^/      /' || true
    fi
}

if [ -z "$SVG_INPUT" ]; then
    if interactive; then
        step "SVG artwork"
        note "from $SVG_DIR:"
        list_svgs
    fi
    SVG_INPUT="$(ask 'SVG file name')"
fi
SVG_INPUT="$(trim "$SVG_INPUT")"
[ -n "$SVG_INPUT" ] || die "SVG file name is empty"

# Bare name -> look it up in the config's svg_directory; anything with a slash is
# taken as a path the user means literally.
case "$(basename "$SVG_INPUT")" in
    *.*) ;;                       # already has an extension, leave it alone
    *)   SVG_INPUT="$SVG_INPUT.svg" ;;
esac
case "$SVG_INPUT" in
    /*)  SVG_PATH="$SVG_INPUT" ;;
    */*) SVG_PATH="$(cd "$(dirname "$SVG_INPUT")" 2>/dev/null && pwd || true)/$(basename "$SVG_INPUT")" ;;
    *)   SVG_PATH="$SVG_DIR/$SVG_INPUT" ;;
esac
if [ ! -f "$SVG_PATH" ]; then
    warn "no such SVG: $SVG_PATH"
    if [ -d "$SVG_DIR" ]; then
        info "  available in $SVG_DIR:"
        list_svgs
    fi
    die "pick one of the files above, or pass a path to --svg"
fi

if [ -z "$SVG_SCALE" ]; then
    interactive && step "SVG scale"
    SVG_SCALE="$(ask 'Blade_Cutout_SVG_Scale (percent)' "$DEFAULT_SCALE")"
fi
SVG_SCALE="$(trim "$SVG_SCALE")"
case "$SVG_SCALE" in
    ''|*[!0-9.]*) die "SVG scale must be a number, got \"$SVG_SCALE\"" ;;
esac
awk -v v="$SVG_SCALE" 'BEGIN { exit (v >= 5 && v <= 500) ? 0 : 1 }' \
    || die "SVG scale must be between 5 and 500 (the .scad's range), got $SVG_SCALE"

# --- what to generate -----------------------------------------------------------

KNOWN_OUTPUTS="stl 3mf colored assembled png"

# Normalises one name from a CSV list or the config, or dies naming what is valid.
canonical_output() {
    case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
        stl)                          printf 'stl' ;;
        3mf)                          printf '3mf' ;;
        colored|color|3mfcolor)       printf 'colored' ;;
        assembled|assembly|stlcolor)  printf 'assembled' ;;
        png|image)                    printf 'png' ;;
        *) die "unknown file type \"$1\" - use $(printf '%s' "$KNOWN_OUTPUTS" | tr ' ' ',')" ;;
    esac
}

# --resulting-files says exactly what to produce, so it replaces the config's
# default_outputs and wins over --no-models / --no-image.
REQUESTED="$DEFAULT_OUTPUTS"
if [ -n "$RESULTING_FILES" ]; then
    REQUESTED="$(printf '%s' "$RESULTING_FILES" | tr ',' ' ')"
fi

# Canonicalise, drop duplicates, and keep them in the order they are rendered in
# rather than the order they were typed.
OUTPUTS=""
for want in $REQUESTED; do
    want="$(trim "$want")"
    [ -n "$want" ] || continue
    canon="$(canonical_output "$want")"
    case " $OUTPUTS " in *" $canon "*) continue ;; esac
    OUTPUTS="$OUTPUTS $canon"
done

# The older switches still work, as filters over that selection.
FILTERED=""
for o in $OUTPUTS; do
    case "$o" in
        png)      [ "$DO_IMAGE"  -eq 1 ] || continue ;;
        *)        [ "$DO_MODELS" -eq 1 ] || continue ;;
    esac
    FILTERED="$FILTERED $o"
done

ORDERED=""
for o in $KNOWN_OUTPUTS; do
    case " $FILTERED " in *" $o "*) ORDERED="$ORDERED $o" ;; esac
done
OUTPUTS="${ORDERED# }"

[ -n "$OUTPUTS" ] || die "nothing left to generate - use $(printf '%s' "$KNOWN_OUTPUTS" | tr ' ' ',')"

# --- sizes to render ----------------------------------------------------------

SIZES=""
if [ -n "$SIZES_FILTER" ]; then
    OLD_IFS="$IFS"; IFS=','
    for want in $SIZES_FILTER; do
        want="$(trim "$want")"
        [ -n "$want" ] || continue
        found=""
        OLD2="$IFS"; IFS=$'\n'
        for have in $ALL_SIZES; do
            [ "$have" = "$want" ] && found="$have"
        done
        IFS="$OLD2"
        [ -n "$found" ] || { IFS="$OLD_IFS"; die "unknown size \"$want\" - the config defines:$ALL_SIZES"; }
        SIZES="$SIZES
$found"
    done
    IFS="$OLD_IFS"
    [ -n "$SIZES" ] || die "--sizes matched nothing"
else
    SIZES="$ALL_SIZES"
fi

# --- render -------------------------------------------------------------------

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/temple-fans.XXXXXX")"
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

# All three sizes of one temple go in a folder of their own inside the output
# directory, so a run's worth of files stays together.
FAN_DIR="$OUT_DIR"
if [ -n "$FOLDER_TEMPLATE" ]; then
    FOLDER_NAME="${FOLDER_TEMPLATE//\{temple\}/$TEMPLE}"
    FAN_DIR="$OUT_DIR/$FOLDER_NAME"
fi

if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$FAN_DIR"
fi

step "Rendering"
note "temple    : $TEMPLE"
note "svg       : $SVG_PATH"
note "svg scale : $SVG_SCALE%"
note "generator : $SCAD_FILE"
note "output    : $FAN_DIR"
note "sizes     :$(printf '%s' "$SIZES" | tr '\n' ' ')"
info ""

# Runs OpenSCAD, quietly unless it fails or --verbose is on.
run_openscad() { # run_openscad <label> <logfile> <args...>
    local label="$1" log="$2"; shift 2
    if [ "$DRY_RUN" -eq 1 ]; then
        # Quoted so the line can be pasted straight into a shell - these paths are full
        # of spaces and an @ sign.
        local shown; shown="$(printf '%q' "$OPENSCAD")"
        local a
        for a in "$@" "$SCAD_FILE"; do shown="$shown $(printf '%q' "$a")"; done
        printf '  %s%s%s\n' "$C_DIM" "$shown" "$C_OFF"
        return 0
    fi
    local start=$SECONDS
    if [ "$VERBOSE" -eq 1 ]; then
        if ! "$OPENSCAD" "$@" "$SCAD_FILE" 2>&1 | tee "$log"; then
            warn "$label failed"
            return 1
        fi
    elif ! "$OPENSCAD" "$@" "$SCAD_FILE" > "$log" 2>&1; then
        warn "$label failed - last lines of $log:"
        tail -n 20 "$log" >&2
        return 1
    fi
    note "$label done in $((SECONDS - start))s"
    return 0
}

FAILURES=0
GENERATED=""
SKIPPED=0

OLD_IFS="$IFS"; IFS=$'\n'
for SIZE in $SIZES; do
    IFS="$OLD_IFS"

    BASE_NAME="$NAME_TEMPLATE"
    BASE_NAME="${BASE_NAME//\{temple\}/$TEMPLE}"
    BASE_NAME="${BASE_NAME//\{size\}/$SIZE}"

    # One OpenSCAD parameter set file per size, holding a variant per kind of output -
    # the same fan throughout, differing only in Rendering_Mode and whatever that
    # variant's own parameters block overrides.
    SET_FILE="$WORK_DIR/$SIZE.json"
    jq --arg size "$SIZE" \
       --arg svg "$SVG_PATH" \
       --arg scale "$SVG_SCALE" \
       --arg models_mode "$MODELS_MODE" \
       --arg image_mode "$IMAGE_MODE" \
       --argjson variants "$VARIANTS_JSON" '
        . as $cfg
        | (($cfg.parameters // {})
           + ((first($cfg.sizes[]? | select(.name == $size)) | .parameters) // {})
           + { Blade_Cutout_SVG_File: $svg,
               Blade_Cutout_SVG_Scale: $scale }) as $p
        | { fileFormatVersion: "1",
            parameterSets: (
              { models: ($p + { Rendering_Mode: $models_mode } + ($cfg.models.parameters // {})),
                image:  ($p + { Rendering_Mode: $image_mode  } + ($cfg.image.parameters  // {})) }
              + (reduce $variants[] as $v ({};
                   . + { ($v): ($p
                                + { Rendering_Mode: ($cfg[$v].rendering_mode // "printing") }
                                + ($cfg[$v].parameters // {})) }))
            ) }
       ' "$CONFIG" > "$SET_FILE" \
       || die "could not build the parameter set for $SIZE"

    printf '%s%s%s (%s)\n' "$C_BOLD" "$BASE_NAME" "$C_OFF" \
        "Area_2_Length=$(jq -r '.parameterSets.models.Area_2_Length // "?"' "$SET_FILE")"

    # One OpenSCAD call per output. Passing several -o flags at once looks tempting but
    # --export-format is global, so asking for binary STL that way would write the .3mf
    # as an STL too - and OpenSCAD re-evaluates the geometry per -o anyway, so splitting
    # the calls costs nothing.
    for out in $OUTPUTS; do
        var_ext=""; var_fmt=""
        case " $VARIANT_OUTPUTS " in
            *" $out "*)
                var_ext="$(out_cfg "$out" extension 3mf)"
                var_fmt="$(out_cfg "$out" stl_format binstl)"
                file_name="$BASE_NAME$(out_cfg "$out" suffix " - $out").$var_ext"
                ;;
            *)
                case "$out" in
                    stl|3mf) file_name="$BASE_NAME.$out" ;;
                    png)     file_name="$BASE_NAME.png" ;;
                esac
                ;;
        esac
        target="$FAN_DIR/$file_name"

        if [ "$SKIP_EXISTING" -eq 1 ] && [ -f "$target" ]; then
            note "skipping existing $file_name"
            SKIPPED=$((SKIPPED + 1))
            continue
        fi

        case "$out" in
            stl|3mf)
                set -- -p "$SET_FILE" -P models
                if [ "$out" = "stl" ] && [ -n "$STL_FORMAT" ]; then
                    set -- "$@" --export-format="$STL_FORMAT"
                fi
                if [ "$out" = "3mf" ]; then
                    for kv in $THREEMF_OPTS; do set -- "$@" -O "export-3mf/$kv"; done
                fi
                set -- "$@" -o "$target"
                ;;
            assembled|colored)
                set -- -p "$SET_FILE" -P "$out"
                if [ "$var_ext" = "stl" ] && [ -n "$var_fmt" ]; then
                    set -- "$@" --export-format="$var_fmt"
                fi
                if [ "$var_ext" = "3mf" ]; then
                    for kv in $THREEMF_OPTS; do set -- "$@" -O "export-3mf/$kv"; done
                fi
                set -- "$@" -o "$target"
                ;;
            png)
                set -- -p "$SET_FILE" -P image --imgsize="$IMG_SIZE" -o "$target"
                # Full geometry evaluation, not OpenCSG preview - far quicker on a fan
                # this dense, and it does not speckle where the etch layer meets the
                # blade face.
                if [ "$IMG_RENDER" = "true" ]; then set -- "$@" --render; fi
                if [ -n "$IMG_CAMERA" ]; then set -- "$@" --camera="$IMG_CAMERA"; fi
                if [ -n "$IMG_PROJECTION" ]; then set -- "$@" --projection="$IMG_PROJECTION"; fi
                if [ "$IMG_VIEWALL" = "true" ]; then set -- "$@" --viewall; fi
                if [ "$IMG_AUTOCENTER" = "true" ]; then set -- "$@" --autocenter; fi
                if [ -n "$IMG_COLORSCHEME" ]; then set -- "$@" --colorscheme="$IMG_COLORSCHEME"; fi
                ;;
        esac

        if run_openscad "$file_name" "$WORK_DIR/$SIZE-$out.log" "$@"; then
            GENERATED="$GENERATED
$target"
        else
            FAILURES=$((FAILURES + 1))
        fi
    done

    info ""
    IFS=$'\n'
done
IFS="$OLD_IFS"

# --- summary ------------------------------------------------------------------

if [ "$DRY_RUN" -eq 1 ]; then
    step "Dry run - nothing was written"
    exit 0
fi

step "Done"
OLD_IFS="$IFS"; IFS=$'\n'
for f in $GENERATED; do
    [ -n "$f" ] || continue
    if [ -f "$f" ]; then
        printf '    %s  %s\n' "$(du -h "$f" | cut -f1)" "$(basename "$f")"
    else
        warn "expected but missing: $f"
        FAILURES=$((FAILURES + 1))
    fi
done
IFS="$OLD_IFS"
note "in $FAN_DIR"
[ "$SKIPPED" -eq 0 ] || note "$SKIPPED file(s) skipped because they already existed"

if [ "$FAILURES" -gt 0 ]; then
    die "$FAILURES step(s) failed - rerun with --verbose to see OpenSCAD's output"
fi
