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
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { PIPELINE } from './workflows/pipeline' //addParams( summary_params: summary_params )

workflow  NFCORE_BENCHMARK {
    // include { RUN_PIPELINE } from './dynamic_template/test_pipeline' //addParams( summary_params: summary_params )
    // include { RUN_PIPELINE } from "./tmp/$module_script"
    // RUN_PIPELINE ()
    PIPELINE ()
}

workflow {
    NFCORE_BENCHMARK ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
