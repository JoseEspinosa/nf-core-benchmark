/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

def valid_params = [
    // assemblers  : ['spades', 'unicycler', 'minia'],
    // spades_modes: ['rnaviral', 'corona', 'metaviral', 'meta', 'metaplasmid', 'plasmid', 'isolate', 'rna', 'bio']
]

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowPipeline.initialise(params, log, valid_params)

// Check input path parameters to see if they exist
def checkPathParamList = [
    params.benchmarker_path, params.multiqc_config
]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Stage dummy file to be used as an optional input where required
ch_dummy_file = file("$projectDir/assets/dummy_file.txt", checkIfExists: true)

/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

// ch_multiqc_config        = file("$projectDir/assets/multiqc_config_illumina.yaml", checkIfExists: true) //TODO
// ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

// Don't overwrite global params.modules, create a copy instead and use that within the main script.

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//


/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary
def multiqc_report    = []
def pass_mapped_reads = [:]
def fail_mapped_reads = [:]

// TODO this should be rename to WorkflowCommons or something
module_script = WorkflowPipeline.createModuleScript(params.benchmarker, workflow, 'benchmarker') //#DEL substitute by params.pipeline

include { RUN_BENCHMARKER } from "$projectDir/tmp/$module_script"
include { MEAN_SCORE      } from "$projectDir/modules/local/mean_score"

workflow BENCHMARKER {

    take:
    output_pipeline

    // ch_software_versions = Channel.empty()
    main:
    RUN_BENCHMARKER (output_pipeline)

    RUN_BENCHMARKER.out \
        | map { it.text } \
        | collectFile (name: 'scores.csv', newLine: false) \
        | set { scores }

    MEAN_SCORE(scores) | view

    emit:
    // RUN_BENCHMARKER.out
    MEAN_SCORE.out
}

/*
========================================================================================
    THE END
========================================================================================
*/
