/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

def valid_params = [
    // protocols   : ['metagenomic', 'amplicon'],
    // callers     : ['ivar', 'bcftools'],
]

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowPipeline.initialise(params, log, valid_params)

// Check input path parameters to see if they exist
def checkPathParamList = [
    params.pipeline_path, params.multiqc_config
]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } } //aqui!!!

// Stage dummy file to be used as an optional input where required
ch_dummy_file = file("${projectDir}/assets/dummy_file.txt", checkIfExists: true)

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

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//


/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULE: Installed directly from nf-core/modules
//

//
// SUBWORKFLOW: Consisting entirely of nf-core/modules
//

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary
def multiqc_report    = []
def pass_mapped_reads = [:]
def fail_mapped_reads = [:]

// params.workflow_name = 'NFCORE_VIRALRECON'
// params.pipeline_name = 'viralrecon'
module_script = WorkflowCommons.createModuleScript(params, workflow, log, 'pipeline', params.pipeline, params.pipeline_workflow_name)

include { RUN_PIPELINE } from "${params.benchmark_work}/${module_script}"

workflow PIPELINE {

    ch_software_versions = Channel.empty()

    main:
    RUN_PIPELINE ()

    emit:
    pipeline = RUN_PIPELINE.out
}

/*
========================================================================================
    THE END
========================================================================================
*/
