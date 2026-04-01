#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def multiqc_output = params.multiqc_output ?: "multiqc_output"

process multiqc_collect {
  tag "multiqc"
  stageInMode 'symlink'
  stageOutMode 'move'

  publishDir "${params.project_folder}/${multiqc_output}", mode: 'copy'

  input:
    val run_id

  output:
    path "${params.multiqc_report_name}"
    path "multiqc_data", optional: true

  script:
  def flatRoot = params.flat_output_root ? params.flat_output_root.toString() : null
  def default_paths = [
    flatRoot
      ? "${flatRoot}/fastqc_output"
      : "${params.pipelines_root}/nf-fastqc/fastqc_output",
    flatRoot
      ? "${flatRoot}/fastp_output"
      : "${params.pipelines_root}/nf-fastp/fastp_output",
    flatRoot
      ? "${flatRoot}/cutadapt_output"
      : "${params.pipelines_root}/nf-cutadapt/cutadapt_output",
    flatRoot
      ? "${flatRoot}/bwa_output"
      : "${params.pipelines_root}/nf-bwa/bwa_output",
    flatRoot
      ? "${flatRoot}/picard_output"
      : "${params.pipelines_root}/nf-picard/picard_output",
    flatRoot
      ? "${flatRoot}/chipfilter_output"
      : "${params.pipelines_root}/nf-chipfilter/chipfilter_output",
    flatRoot
      ? "${flatRoot}/macs3_output"
      : "${params.pipelines_root}/nf-macs3/macs3_output",
    flatRoot
      ? "${flatRoot}/idr_output"
      : "${params.pipelines_root}/nf-idr/idr_output",
    flatRoot
      ? "${flatRoot}/idr_pseudo_output"
      : "${params.pipelines_root}/nf-idr-pseudo/idr_pseudo_output",
    flatRoot
      ? "${flatRoot}/chipseeker_output"
      : "${params.pipelines_root}/nf-chipseeker/chipseeker_output",
    flatRoot
      ? "${flatRoot}/frip_output"
      : "${params.pipelines_root}/nf-frip/frip_output",
    flatRoot
      ? "${flatRoot}/bamcoverage_output"
      : "${params.pipelines_root}/nf-bamcoverage/bamcoverage_output",
    flatRoot
      ? "${flatRoot}/deeptools_heatmap_output"
      : "${params.pipelines_root}/nf-deeptools-heatmap/deeptools_heatmap_output",
    flatRoot
      ? "${flatRoot}/diffbind_output"
      : "${params.pipelines_root}/nf-diffbind/diffbind_output",
    flatRoot
      ? "${flatRoot}/homer_output"
      : "${params.pipelines_root}/nf-homer/homer_output",
    flatRoot
      ? "${flatRoot}/result_delivery_output"
      : "${params.pipelines_root}/nf-result-delivery/result_delivery_output"
  ]

  def extra_paths = []
  if (params.multiqc_extra_paths) {
    extra_paths = params.multiqc_extra_paths.toString().split(',').collect { it.trim() }.findAll { it }
  }

  def all_paths = (default_paths + extra_paths).unique()
  def cli_paths = all_paths.collect { "\"${it}\"" }.join(' ')
  def report_name = params.multiqc_report_name ?: "multiqc_report.html"
  def title_arg = params.multiqc_title ? "--title \"${params.multiqc_title}\"" : ""
  def force_arg = (params.multiqc_force == null || params.multiqc_force) ? "--force" : ""
  def config_arg = (params.multiqc_config && file(params.multiqc_config.toString()).exists())
    ? "--config \"${params.multiqc_config}\""
    : ""

  """
  set -euo pipefail

  mkdir -p tmp
  export TMPDIR=\$PWD/tmp
  export TEMP=\$PWD/tmp
  export TMP=\$PWD/tmp

  SEARCH_PATHS=(${cli_paths})
  VALID_PATHS=()
  for p in "\${SEARCH_PATHS[@]}"; do
    if [[ -e "\$p" ]]; then
      VALID_PATHS+=("\$p")
    fi
  done

  if [[ "\${#VALID_PATHS[@]}" -eq 0 ]]; then
    echo "ERROR: No existing input path found for MultiQC." >&2
    echo "Checked paths:" >&2
    printf '  %s\n' "\${SEARCH_PATHS[@]}" >&2
    exit 1
  fi

  multiqc \\
    \${VALID_PATHS[@]} \\
    --filename "${report_name}" \\
    ${title_arg} \\
    ${force_arg} \\
    ${config_arg} \\
    --outdir .
  """
}

workflow {
  Channel
    .value("run")
    .set { ch_once }

  multiqc_collect(ch_once)
}
