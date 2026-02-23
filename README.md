# nf-multiqc

Single-tool Nextflow DSL2 module for collecting ChIP-seq module outputs into one MultiQC report.

## What This Module Does

`nf-multiqc` scans output directories from your upstream modules and builds:
- one HTML report (`multiqc_report.html` by default)
- one `multiqc_data/` folder (parsed tables and logs)

It is designed as the final QC aggregation step after your pipeline modules finish.

## Default Input Search Paths

By default it checks these directories under `--pipelines_root`:

- `nf-fastqc/fastqc_output`
- `nf-fastp/fastp_output`
- `nf-cutadapt/cutadapt_output`
- `nf-bwa/bwa_output`
- `nf-picard/picard_output`
- `nf-chipfilter/chipfilter_output`
- `nf-macs3/macs3_output`
- `nf-idr/idr_output`
- `nf-idr-pseudo/idr_pseudo_output`
- `nf-chipseeker/chipseeker_output`
- `nf-frip/frip_output`
- `nf-bamcoverage/bamcoverage_output`
- `nf-deeptools-heatmap/deeptools_heatmap_output`
- `nf-diffbind/diffbind_output`
- `nf-homer/homer_output`
- `nf-result-delivery/result_delivery_output`

Only existing paths are used. If none exists, the module exits with an error.

## Parameters

Main parameters in `nextflow.config`:

- `project_folder`: where `multiqc_output/` is written
- `pipelines_root`: root directory that contains all module folders
- `multiqc_output`: output folder name (default: `multiqc_output`)
- `multiqc_report_name`: output HTML name (default: `multiqc_report.html`)
- `multiqc_title`: report title
- `multiqc_force`: overwrite old report (`true` by default)
- `multiqc_extra_paths`: comma-separated extra dirs to include
- `multiqc_config`: optional custom MultiQC YAML config
- `container_multiqc`: MultiQC container path for HPC profile

## Run

### HPC

```bash
cd /ictstr01/groups/idc/projects/uhlenhaut/jiang/pipelines/nf-multiqc
nextflow run main.nf -profile hpc \
  --pipelines_root /ictstr01/groups/idc/projects/uhlenhaut/jiang/pipelines \
  -resume
```

### Add extra paths

```bash
nextflow run main.nf -profile hpc \
  --pipelines_root /ictstr01/groups/idc/projects/uhlenhaut/jiang/pipelines \
  --multiqc_extra_paths "/path/a,/path/b" \
  -resume
```

### With custom MultiQC config

```bash
nextflow run main.nf -profile hpc \
  --pipelines_root /ictstr01/groups/idc/projects/uhlenhaut/jiang/pipelines \
  --multiqc_config /path/to/multiqc_config.yaml \
  -resume
```

## Output

Published to:

- `${project_folder}/${multiqc_output}/${multiqc_report_name}`
- `${project_folder}/${multiqc_output}/multiqc_data/`

With default config this is usually:

- `./multiqc_output/multiqc_report.html`
- `./multiqc_output/multiqc_data/`

## Integration in End-to-End Pipeline

`nextflow-chipseq/run_end2end.sh` now supports this final step:

- `RUN_MULTIQC=true|false`
- `MULTIQC_TITLE`
- `MULTIQC_REPORT_NAME`
- `MULTIQC_EXTRA_PATHS`
- `MULTIQC_CONFIG`

Set them in `pipeline.env` and run `run_end2end.sh` as usual.
