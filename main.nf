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

include { PIPELINE }    from './workflows/pipeline' //addParams( summary_params: summary_params )

params.skip_benchmark = false
include { BENCHMARKER } from './workflows/benchmarker'

workflow  NFCORE_BENCHMARK {
    // include { RUN_PIPELINE } from './dynamic_template/test_pipeline' //addParams( summary_params: summary_params )
    // include { RUN_PIPELINE } from "./tmp/$module_script"
    // RUN_PIPELINE ()
    PIPELINE ()

    // PIPELINE.out.pipeline.view()

    // By default take ".out" if provided (or exists) then used the named output (params.pipeline_output_name)
    if (!params.skip_benchmark) {

        // PIPELINE.out.pipeline.view()

        // By default take ".out" if provided (or exists) then used the named output (params.pipeline_output_name)
        // if (!params.pipeline_output_name) {
    //         output_to_benchmark = PIPELINE.out[1]
    //         PIPELINE.out[0].view() //tcoffee
    //         // output_to_benchmark = PIPELINE.out[0] //tcoffee
    //     }
    //     else {
    //         output_to_benchmark = PIPELINE.out."$params.pipeline_output_name"
    //     }

    //     // log.info """
    //     // Benchmark: ${infoBenchmark.benchmarker}
    //     // """.stripIndent()

         BENCHMARKER (PIPELINE.out.pipeline)
    }
    //     BENCHMARKER.out \
    //          | map { it.text } \
    //          | collectFile (name: 'scores.csv', newLine: false) \
    //          | set { scores }
    //     // TODO: output sometimes could be more than just a single score, refactor to be compatible with these cases
    //     MEAN_BENCHMARK_SCORE(scores) | view

    //     emit:
    //     BENCHMARK.out
    // }
}

workflow {
    NFCORE_BENCHMARK ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
