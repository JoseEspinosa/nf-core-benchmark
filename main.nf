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
    PIPELINE PARAMETER VALUES
========================================================================================
*/
// "${params.pipeline_path}/meta.yml"
// params.yaml_pipeline
// params.csv_methods

/*
========================================================================================
    BENCHMARKER PARAMETER VALUES
========================================================================================
*/

params.benchmarker = WorkflowMain.getBenchmarker(workflow, params, log)
params.skip_benchmark = false

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
    THE END
========================================================================================
*/
