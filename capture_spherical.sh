#!/usr/bin/env bash
# Capture the two MaidenLane wiki screenshots for the spherical pipeline.
# Spherical reconstructions come out upside-down in the Viewer (the cube-map face
# orientation flips Y); we fix that by rotating the captured JPG 180° with ffmpeg.
set -uo pipefail
V="/c/Users/danco/Pro/openMVS/make/bin/vc18/x64/RelWithDebInfo/Viewer.exe"
cd "$(dirname "$0")"

shot() {
  local out="$1"; shift
  echo ">>> $out"
  rm -f "$out"
  for try in 1 2 3 4; do
    timeout 240 "$V" "$@" --screenshot-file "$out" >/dev/null 2>&1 || true
    [ -s "$out" ] && return 0
    echo "   retry $try ($out)"; sleep 2
  done
  echo "FAILED: $out"; exit 1
}

# Rotate a JPG 180° in place (spherical Viewer captures are upside-down).
rotate180() {
  local f="$1"
  local tmp="${f%.jpg}_rot.jpg"
  ffmpeg -y -loglevel error -i "$f" -vf "transpose=2,transpose=2" -q:v 2 "$tmp" \
    && mv -f "$tmp" "$f"
}

# scene_keyframes.jpg: keyframe camera frustums + sparse SfM points seen from
# inside the hall (camera 18, matches keyframe_00018). Rotated 180° to flip the
# spherical-camera Y-axis convention.
shot scene_keyframes.jpg       -i scene.mvs        --view-camera 18 --screenshot-show pc
rotate180 scene_keyframes.jpg

# scene_spherical_dense_mesh.jpg: refined untextured mesh from a mid-stream
# spherical keyframe looking down the hall. MVS expands each spherical frame
# into 6 cube-map sub-cameras, so the Viewer's --view-camera index is
# 6 × SfM-keyframe + face_index; here SfM keyframe 5 (center of 11) × 6 = 30
# picks the +X face that frames the two archways inside the building.
shot scene_spherical_dense_mesh.jpg -i scene_dense.mvs -g scene_dense_mesh_refine.ply --view-camera 30 --screenshot-show m
rotate180 scene_spherical_dense_mesh.jpg

# scene_spherical_dense.jpg: refined textured mesh from the same interior keyframe.
# Close-up coverage shows the texture detail; rotate 180° same as above.
shot scene_spherical_dense.jpg -i scene_dense.mvs  -g scene_dense_mesh_refine_texture.ply --view-camera 18 --screenshot-show mt
rotate180 scene_spherical_dense.jpg

echo "### SPHERICAL CAPTURE DONE ###"
ls -la scene_keyframes.jpg scene_spherical_dense_mesh.jpg scene_spherical_dense.jpg
