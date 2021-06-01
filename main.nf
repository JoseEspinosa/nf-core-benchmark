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

params.pipeline_path = "${params.pipelines_dir}/${params.pipeline}/main.nf"

/*
========================================================================================
    BENCHMARKER PARAMETER VALUES
========================================================================================
*/

params.skip_benchmark   = false
params.benchmarker      = WorkflowMain.getBenchmarker(workflow, params, log) // si se saca con la funcion tiene que ser parametro tb?
params.benchmarker_path = "${params.benchmarkers_dir}/${params.benchmarker}/main.nf"

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
