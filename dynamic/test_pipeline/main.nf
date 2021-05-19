#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//
// This is an intermediary file that eventually should be generated dynamically by the pipeline
//

// variables to generate the dynamic script:
// pipeline_name: "tcoffee" --> also in capitals or convert (pipeline_name_capitals)

include { TCOFFEE } from "${projectDir}/pipelines/tcoffee/main.nf" //VARIABLE here

workflow TEST_PIPELINE {

    TCOFFEE() //VARIABLE here
}

workflow {
    TEST_PIPELINE()
}

