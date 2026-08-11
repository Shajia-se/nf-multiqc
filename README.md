# nf-multiqc

`nf-multiqc` builds a MultiQC report from module output folders.

## Recommended Input

Use the flat run root from `nextflow-chipseq`:

```bash
--flat_output_root /path/to/run_root
```

The module scans standard subfolders such as `fastqc_output`, `fastp_output`, `bwa_output`, `picard_output`, and others when they exist.

## Output

```text
${project_folder}/${multiqc_output}/multiqc_report.html
```

## Run

```bash
nextflow run main.nf -profile hpc \
  --flat_output_root /path/to/run_root \
  --project_folder /path/to/output_project
```

Actual execution should be tested where Nextflow is installed.
