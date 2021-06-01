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

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [
    params.input, params.multiqc_config//, params.fasta
    //params.input, params.fasta, params.gff, params.bowtie2_index,
    // params.kraken2_db, params.primer_bed, params.primer_fasta,
    // params.blast_db, params.spades_hmm, params.multiqc_config
]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Stage dummy file to be used as an optional input where required
ch_dummy_file = file("$projectDir/assets/dummy_file.txt", checkIfExists: true)

benchmarker_module = file( "${params.path_to_benchmarkers}/${params.benchmarker}/main.nf" )

// TODO adapt to pipeline
if (params.input)      { ch_input      = file(params.input)      } else { exit 1, 'Input samplesheet file not specified!' }
// TODO define params such as in the case of viralrecon e.g. params.pipeline
// TODO use variable for name of pipeline i.e. nf-benchmark
if( !benchmarker_module.exists() ) exit 1, "ERROR: The selected benchmarker is not correctly included in nf-benchmark: ${benchmarker_module}"

// if (params.spades_hmm) { ch_spades_hmm = file(params.spades_hmm) } else { ch_spades_hmm = ch_dummy_file                   } //delete

/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

// ch_multiqc_config        = file("$projectDir/assets/multiqc_config_illumina.yaml", checkIfExists: true) //TODO
// ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

// Header files // TODO add if needed
// ch_blast_outfmt6_header     = file("$projectDir/assets/headers/blast_outfmt6_header.txt", checkIfExists: true)
// ch_ivar_variants_header_mqc = file("$projectDir/assets/headers/ivar_variants_header_mqc.txt", checkIfExists: true)

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

//
// SUBWORKFLOW: Consisting entirely of nf-core/modules
//
// def fastp_options = modules['illumina_fastp']
// if (params.save_trimmed_fail) { fastp_options.publish_files.put('fail.fastq.gz','') }

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
