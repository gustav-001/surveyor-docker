# surveyor-docker

Docker image for [SurVeyor](https://github.com/Mesh89/SurVeyor) v0.12.1 — a paired-end short-read SV caller.

Built for clinical bioinformatics use as part of an SV annotation/filtering internship at CMGG Ghent.

## Image

Pull the prebuilt image from GHCR:

```bash
docker pull ghcr.io/gustav-001/surveyor:0.12.1
```

Or as a Singularity/Apptainer image on HPC:

```bash
singularity pull $VSC_SCRATCH/singularity/surveyor_0.12.1.sif \
  docker://ghcr.io/gustav-001/surveyor:0.12.1
```

## Usage

```bash
singularity exec surveyor_0.12.1.sif \
  python3 /opt/SurVeyor/surveyor.py call --threads N \
    INPUT.bam WORKDIR REFERENCE.fa \
    --ml-model /opt/SurVeyor/trained-model
```

## Build details

- Multi-stage Dockerfile: builder (compilers + dev headers) → slim runtime
- Built for `linux/amd64` (cross-compiled from ARM via `docker buildx`)
- Python deps pinned: `numpy==2.2.6`, `pysam==0.24.0`, `scikit-learn==1.7.2`, `xgboost==3.2.0`
- Bundled htslib 1.21 (built from source via SurVeyor's `build_htslib.sh`)
- Trained ML model baked into image at `/opt/SurVeyor/trained-model`
