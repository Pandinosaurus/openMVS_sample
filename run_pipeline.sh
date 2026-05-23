#!/usr/bin/env bash
# SceauxCastle full OpenMVS pipeline using the native SfM module.
# Run from C:\Pro\Datasets\SceauxCastle\sample
set -euo pipefail
BIN="/c/Pro/openMVS/make/bin/vc18/x64/Release"
IMAGES="C:/Pro/Datasets/SceauxCastle/images"
cd "$(dirname "$0")"

echo "### clean stale dmaps ###"
rm -f ./*.dmap

step() { echo; echo "########## $* ##########"; }

step "1/7 CreateStructure (native SfM)"
"$BIN/CreateStructure.exe" -s "$IMAGES" -o scene.sfm --export-mvs scene.mvs --extract-colors 1

step "2/7 DensifyPointCloud"
"$BIN/DensifyPointCloud.exe" scene.mvs

step "3/7 ReconstructMesh (rough mesh from sparse)"
"$BIN/ReconstructMesh.exe" scene.mvs --remove-spurious 4 --close-holes 30 --smooth 2

step "4/7 ReconstructMesh (mesh from dense)"
"$BIN/ReconstructMesh.exe" scene_dense.mvs -p scene_dense.ply

step "5/7 RefineMesh (sparse mesh)"
"$BIN/RefineMesh.exe" scene.mvs -m scene_mesh.ply -o scene_mesh_refine.mvs

step "6/7 RefineMesh (dense mesh)"
"$BIN/RefineMesh.exe" scene_dense.mvs -m scene_dense_mesh.ply -o scene_dense_mesh_refine.mvs --scales 1 --max-face-area 16

step "7/7 TextureMesh"
"$BIN/TextureMesh.exe" scene_dense.mvs -m scene_dense_mesh_refine.ply -o scene_dense_mesh_refine_texture.mvs

echo
echo "### PIPELINE DONE ###"
ls -la ./*.mvs ./*.ply ./*.dmap 2>/dev/null
