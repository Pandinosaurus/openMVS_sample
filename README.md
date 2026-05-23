# openMVS_sample

Complete reference data for the [OpenMVS](https://github.com/cdcseacave/openMVS) wiki [usage walkthrough](https://github.com/cdcseacave/openMVS/wiki/Usage). All artifacts here are produced automatically by the OpenMVS pipeline, with no manual editing of the results.

## What's in here

Two datasets, both regenerated end-to-end with current OpenMVS apps:

- **Sceaux Castle** ([source images](https://github.com/openMVG/ImageDataset_SceauxCastle), in `images/`) — 11 photos, the canonical pinhole demo. Reconstructed with the **native OpenMVS SfM** module (`CreateStructure`); the older OpenMVG-based input is no longer required.
- **Spherical 360°** (`scene_keyframes.jpg`, `scene_spherical_dense.jpg`) — extracted from a 360° equirectangular video by `ExtractKeyframes --camera-type 1`, then reconstructed with the same `CreateStructure`/dense/mesh/texture chain. Heavy artifacts (`.mvs`/`.ply`/keyframes) are not committed here; only the two screenshots used by the wiki are.

## Reproduce locally

The two helper scripts are committed alongside the artifacts:

- `run_pipeline.sh` + `capture.sh` — Sceaux Castle. Edit `BIN=` if your build lives elsewhere, then `bash run_pipeline.sh && bash capture.sh`.
- `run_spherical.sh` + `capture_spherical.sh` — spherical. Edit `BIN=` and `VIDEO=` (the equirectangular `.mp4` source). The capture script flips the captured JPGs 180° via `ffmpeg` to compensate for the upside-down spherical camera convention in the Viewer.

Pre-built OpenMVS binaries for Windows x64 (with and without CUDA), Ubuntu x64 and macOS arm64 are attached to every tagged release on the [OpenMVS releases page](https://github.com/cdcseacave/openMVS/releases/latest).

## Notes

- The sparse-mesh stages (`scene_mesh.{ply,jpg}`, `scene_mesh_refine.{ply,jpg}`) run `ReconstructMesh` with `--remove-spurious 4 --close-holes 30 --smooth 2` instead of the defaults; the defaults leave very long triangles spanning gaps in a sparse cloud, which render as a featureless blob.
- `Sparse.ply` is exported from `scene.mvs` by the Viewer (`Viewer -i scene.mvs -o Sparse.ply --export-type ply` writes `Sparse_pointcloud.ply` first; the capture script renames it).
- `*.log` files are the per-stage console logs OpenMVS emits — useful for sanity-checking what each step did and how long it took.
