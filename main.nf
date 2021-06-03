#!/usr/bin/env nextflow
/*
========================================================================================
    nf-core/benchmark
========================================================================================
    nf-core/benchmark Analysis Pipeline.
    #### Homepage / Documentation
    https://github.com/nf-core/benchmark
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    WORKFLOW VALUES
========================================================================================
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)
def multiqc_report = []

/*
========================================================================================
    PIPELINE PARAMETER VALUES
========================================================================================
*/

params.pipeline_path = "${params.pipelines_dir}/${params.pipeline}/main.nf"

/*
========================================================================================
    BENCHMARKER PARAMETER VALUES
========================================================================================
*/

params.skip_benchmark   = false

if (!params.skip_benchmark) {
    params.benchmarker      = WorkflowMain.getBenchmarker(workflow, params, log)
    params.benchmarker_path = "${params.benchmarkers_dir}/${params.benchmarker}/main.nf"
}

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { PIPELINE }    from './workflows/pipeline' //addParams( summary_params: summary_params )
include { BENCHMARKER } from './workflows/benchmarker'

workflow  NFCORE_BENCHMARK {

    PIPELINE ()

    if (!params.skip_benchmark) {
        BENCHMARKER (PIPELINE.out.pipeline)
    }
}

workflow {
    NFCORE_BENCHMARK ()
}

/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
    NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    NfcoreTemplate.summary(workflow, params, log, fail_mapped_reads, pass_mapped_reads)
}

/*
========================================================================================
    THE END
========================================================================================
*/
