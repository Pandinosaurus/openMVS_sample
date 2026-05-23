#!/usr/bin/env bash
# MaidenLane 360-degree spherical end-to-end OpenMVS pipeline.
# Run from C:\Pro\Datasets\polycam\spherical\MaidenLane\sample
set -euo pipefail
BIN="/c/Pro/openMVS/make/bin/vc18/x64/Release"
VIDEO="C:/Pro/Datasets/polycam/spherical/MaidenLane/33_Maiden_Lane.mp4"
cd "$(dirname "$0")"

rm -f ./*.dmap
step() { echo; echo "########## $* ##########"; }

step "1/6 ExtractKeyframes (spherical)"
"$BIN/ExtractKeyframes.exe" -i "$VIDEO" -o scene_keyframes.sfm -d keyframes --camera-type 1

step "2/6 CreateStructure (native SfM, spherical, reusing keyframe features+matches)"
"$BIN/CreateStructure.exe" -s scene_keyframes.sfm -o scene.sfm --export-mvs scene.mvs --extract-colors 1

step "3/6 DensifyPointCloud"
"$BIN/DensifyPointCloud.exe" scene.mvs

step "4/6 ReconstructMesh"
"$BIN/ReconstructMesh.exe" scene_dense.mvs -p scene_dense.ply

step "5/6 RefineMesh"
"$BIN/RefineMesh.exe" scene_dense.mvs -m scene_dense_mesh.ply -o scene_dense_mesh_refine.mvs --scales 1 --max-face-area 16

step "6/6 TextureMesh (rough + refined)"
"$BIN/TextureMesh.exe" scene_dense.mvs -m scene_dense_mesh.ply -o scene_dense_mesh_texture.mvs
"$BIN/TextureMesh.exe" scene_dense.mvs -m scene_dense_mesh_refine.ply -o scene_dense_mesh_refine_texture.mvs

echo
echo "### SPHERICAL PIPELINE DONE ###"
ls -la ./*.mvs ./*.sfm ./*.ply 2>/dev/null
echo "keyframes:"; ls keyframes 2>/dev/null | wc -l
