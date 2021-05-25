#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//
// This is an intermediary file that eventually should be generated dynamically by the pipeline
//

include { TCOFFEE } from "${projectDir}/pipelines/tcoffee/main.nf" //VARIABLES here
// include { ${module_name_upper_case} } from "../pipelines/${module_name}/main.nf"

workflow RUN_PIPELINE { //VARIABLES here
// workflow RUN_${workflow_name} {

    TCOFFEE() //VARIABLE here
    // ${module_name_upper_case}() //VARIABLES here
}

workflow {
    RUN_PIPELINE()
    // RUN_${workflow_name}() //VARIABLES here
}
