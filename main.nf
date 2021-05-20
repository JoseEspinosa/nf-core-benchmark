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
WorkflowPipeline.createModuleScript('tcoffee')

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

workflow  NFCORE_BENCHMARK {
    // include { RUN_PIPELINE } from './workflows/pipeline' //addParams( summary_params: summary_params )
    include { TEST_PIPELINE } from './dynamic/test_pipeline' //addParams( summary_params: summary_params )
    // TODO Do it the other way around i.e. include the RUN_PIPELINE script and from it create the script and launch
    TEST_PIPELINE ()
}

workflow {
    NFCORE_BENCHMARK ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
