#!/usr/bin/env bash
# Capture all SceauxCastle wiki screenshots + export Sparse.ply
set -uo pipefail
V="/c/Users/danco/Pro/openMVS/make/bin/vc18/x64/RelWithDebInfo/Viewer.exe"
cd "$(dirname "$0")"
CAM=5

# shot <output.jpg> <viewer args...>  (retries the known intermittent init race)
shot() {
  local out="$1"; shift
  echo ">>> $out"
  rm -f "$out"
  for try in 1 2 3 4; do
    timeout 150 "$V" "$@" --screenshot-file "$out" >/dev/null 2>&1 || true
    [ -s "$out" ] && return 0
    echo "   retry $try ($out)"; sleep 2
  done
  echo "FAILED: $out"; exit 1
}

shot Sparse.jpg                          -i scene.mvs       --view-camera $CAM --screenshot-show pc
shot scene_sparse.jpg                    -i scene.mvs       --view-camera 3    --screenshot-show pc
shot scene_dense.jpg                     -i scene_dense.mvs --view-camera $CAM --screenshot-show p
shot depth0001.dmap.jpg                  -i depth0001.dmap --view-camera 0
shot scene_dense_mesh.jpg                -i scene_dense.mvs -g scene_dense_mesh.ply         --view-camera $CAM --screenshot-show m
shot scene_mesh.jpg                      -i scene.mvs       -g scene_mesh.ply              --view-camera $CAM --screenshot-show m
shot scene_mesh_refine.jpg              -i scene.mvs       -g scene_mesh_refine.ply       --view-camera $CAM --screenshot-show m
shot scene_dense_mesh_refine.jpg         -i scene_dense.mvs -g scene_dense_mesh_refine.ply --view-camera $CAM --screenshot-show m
shot scene_dense_mesh_refine_texture.jpg -i scene_dense.mvs -g scene_dense_mesh_refine_texture.ply --view-camera $CAM --screenshot-show mt

echo ">>> export Sparse.ply"
rm -f Sparse.ply Sparse_pointcloud.ply
for try in 1 2 3; do
  timeout 150 "$V" -i scene.mvs -o Sparse.ply --export-type ply >/dev/null 2>&1 || true
  if [ -s Sparse_pointcloud.ply ]; then mv -f Sparse_pointcloud.ply Sparse.ply; fi
  [ -s Sparse.ply ] && break; sleep 2
done
[ -s Sparse.ply ] || { echo "FAILED Sparse.ply"; exit 1; }

echo "### CAPTURE DONE ###"
ls -la *.jpg Sparse.ply
