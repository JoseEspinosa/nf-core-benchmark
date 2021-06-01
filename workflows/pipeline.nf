/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

def valid_params = [
    protocols   : ['metagenomic', 'amplicon'],
    callers     : ['ivar', 'bcftools'],
    assemblers  : ['spades', 'unicycler', 'minia'],
    spades_modes: ['rnaviral', 'corona', 'metaviral', 'meta', 'metaplasmid', 'plasmid', 'isolate', 'rna', 'bio']
]

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowPipeline.initialise(params, log, valid_params)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [
    params.input, params.pipeline_path, params.multiqc_config
]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } } //aqui!!!

// Stage dummy file to be used as an optional input where required
ch_dummy_file = file("$projectDir/assets/dummy_file.txt", checkIfExists: true)

// TODO check in workflow initialize??

//pipeline_module = file( "${params.pipelines_dir}/${params.pipeline}/main.nf" )

// TODO adapt to pipeline
if (params.input)      { ch_input      = file(params.input)      } else { exit 1, 'Input samplesheet file not specified!' }

// TODO define params such as in the case of viralrecon e.g. params.pipeline
// TODO use variable for name of pipeline i.e. nf-benchmark

//if( !pipeline_module.exists() ) exit 1, "ERROR: The selected pipeline is not correctly included in nf-benchmark: ${params.pipeline}"

// if (params.spades_hmm) { ch_spades_hmm = file(params.spades_hmm) } else { ch_spades_hmm = ch_dummy_file                   } //delete



// Pipeline meta-information from the pipeline
yaml_path_pipeline = "${params.pipelines_dir}/${params.pipeline}/meta.yml" //TODO check if exists
csvPathMethods = "${workflow.projectDir}/assets/methods2benchmark.csv"

//pipeline_module = file( "${params.pipeline_path}/main.nf" )

def input_pipeline_param = WorkflowPipeline.setInputParam(yaml_path_pipeline)

// def infoBenchmark = WorkflowPipeline.setBenchmark(params, yaml_path_pipeline, csvPathMethods, params.pipeline, input_pipeline_param)

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

// include { BCFTOOLS_ISEC              } from '../modules/local/bcftools_isec'             addParams( options: modules['illumina_bcftools_isec'] )


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
// include { CAT_FASTQ                     } from '../modules/nf-core/software/cat/fastq/main'                     addParams( options: modules['illumina_cat_fastq']                     )
// include { FASTQC                        } from '../modules/nf-core/software/fastqc/main'                        addParams( options: modules['illumina_cutadapt_fastqc']               )
// include { KRAKEN2_RUN                   } from '../modules/nf-core/software/kraken2/run/main'                   addParams( options: modules['illumina_kraken2_run']                   )
// include { PICARD_COLLECTMULTIPLEMETRICS } from '../modules/nf-core/software/picard/collectmultiplemetrics/main' addParams( options: modules['illumina_picard_collectmultiplemetrics'] )
// include { MOSDEPTH as MOSDEPTH_GENOME   } from '../modules/nf-core/software/mosdepth/main'                      addParams( options: modules['illumina_mosdepth_genome']               )
// include { MOSDEPTH as MOSDEPTH_AMPLICON } from '../modules/nf-core/software/mosdepth/main'                      addParams( options: modules['illumina_mosdepth_amplicon']             )

//
// SUBWORKFLOW: Consisting entirely of nf-core/modules
//
// def fastp_options = modules['illumina_fastp']
// if (params.save_trimmed_fail) { fastp_options.publish_files.put('fail.fastq.gz','') }

// def bowtie2_align_options = modules['illumina_bowtie2_align']
// if (params.save_unaligned) { bowtie2_align_options.publish_files.put('fastq.gz','unmapped') }

// def markduplicates_options   = modules['illumina_picard_markduplicates']
// markduplicates_options.args += params.filter_duplicates ?  Utils.joinModuleArgs(['REMOVE_DUPLICATES=true']) : ''

// include { FASTQC_FASTP           } from '../subworkflows/nf-core/fastqc_fastp'           addParams( fastqc_raw_options: modules['illumina_fastqc_raw'], fastqc_trim_options: modules['illumina_fastqc_trim'], fastp_options: fastp_options )
// include { ALIGN_BOWTIE2          } from '../subworkflows/nf-core/align_bowtie2'          addParams( align_options: bowtie2_align_options, samtools_options: modules['illumina_bowtie2_sort_bam']                                           )
// include { MARK_DUPLICATES_PICARD } from '../subworkflows/nf-core/mark_duplicates_picard' addParams( markduplicates_options: markduplicates_options, samtools_options: modules['illumina_picard_markduplicates_sort_bam']                   )

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary
def multiqc_report    = []
def pass_mapped_reads = [:]
def fail_mapped_reads = [:]

module_script = WorkflowPipeline.createModuleScript(params.pipeline, workflow, 'pipeline') //#DEL substitute by params.pipeline
//  Change to get both params.pipeline and params.pipeline_path //TODO
// module_script = WorkflowPipeline.createModuleScript(params, workflow, 'pipeline') //#DEL substitute by params.pipeline

include { RUN_PIPELINE } from "$projectDir/tmp/$module_script"

workflow PIPELINE {

    ch_software_versions = Channel.empty()

    main:
    RUN_PIPELINE ()

    emit:
    pipeline = RUN_PIPELINE.out
}

/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/
//TODO review according to nfcore/rnaseq,
// here is different since both are run!!!
workflow.onComplete {
    NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report, fail_mapped_reads)
    NfcoreTemplate.summary(workflow, params, log, fail_mapped_reads, pass_mapped_reads)
}

/*
========================================================================================
    THE END
========================================================================================
*/
