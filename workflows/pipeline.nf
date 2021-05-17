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
    params.input, params.multiqc_config, params.fasta
    //params.input, params.fasta, params.gff, params.bowtie2_index,
    // params.kraken2_db, params.primer_bed, params.primer_fasta,
    // params.blast_db, params.spades_hmm, params.multiqc_config
]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Stage dummy file to be used as an optional input where required
ch_dummy_file = file("$projectDir/assets/dummy_file.txt", checkIfExists: true)

// TODO adapt to pipeline
if (params.input)      { ch_input      = file(params.input)      } else { exit 1, 'Input samplesheet file not specified!' }
if (params.spades_hmm) { ch_spades_hmm = file(params.spades_hmm) } else { ch_spades_hmm = ch_dummy_file                   }

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
// include { CUTADAPT                   } from '../modules/local/cutadapt'                  addParams( options: modules['illumina_cutadapt']      )
// include { GET_SOFTWARE_VERSIONS      } from '../modules/local/get_software_versions'     addParams( options: [publish_files: ['csv':'']]       )
// include { MULTIQC                    } from '../modules/local/multiqc_illumina'          addParams( options: multiqc_options                   )
// include { PLOT_MOSDEPTH_REGIONS as PLOT_MOSDEPTH_REGIONS_GENOME   } from '../modules/local/plot_mosdepth_regions' addParams( options: modules['illumina_plot_mosdepth_regions_genome']   )
// include { PLOT_MOSDEPTH_REGIONS as PLOT_MOSDEPTH_REGIONS_AMPLICON } from '../modules/local/plot_mosdepth_regions' addParams( options: modules['illumina_plot_mosdepth_regions_amplicon'] )
// include { MULTIQC_CUSTOM_TWOCOL_TSV as MULTIQC_CUSTOM_TWOCOL_TSV_FAIL_MAPPED       } from '../modules/local/multiqc_custom_twocol_tsv' addParams( options: [publish_files: false]        )
// include { MULTIQC_CUSTOM_TWOCOL_TSV as MULTIQC_CUSTOM_TWOCOL_TSV_IVAR_PANGOLIN     } from '../modules/local/multiqc_custom_twocol_tsv' addParams( options: [publish_files: false]        )
// include { MULTIQC_CUSTOM_TWOCOL_TSV as MULTIQC_CUSTOM_TWOCOL_TSV_BCFTOOLS_PANGOLIN } from '../modules/local/multiqc_custom_twocol_tsv' addParams( options: [publish_files: false]        )

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
// def publish_genome_options    = params.save_reference ? [publish_dir: 'genome']       : [publish_files: false]
// def publish_index_options     = params.save_reference ? [publish_dir: 'genome/index'] : [publish_files: false]
// def publish_db_options        = params.save_reference ? [publish_dir: 'genome/db']    : [publish_files: false]
// def bedtools_getfasta_options = modules['illumina_bedtools_getfasta']
// def bowtie2_build_options     = modules['illumina_bowtie2_build']
// def snpeff_build_options      = modules['illumina_snpeff_build']
// def makeblastdb_options       = modules['illumina_blast_makeblastdb']
// def kraken2_build_options     = modules['illumina_kraken2_build']
// def collapse_primers_options  = modules['illumina_collapse_primers_illumina']
// if (!params.save_reference) {
//     bedtools_getfasta_options['publish_files'] = false
//     bowtie2_build_options['publish_files']     = false
//     snpeff_build_options['publish_files']      = false
//     makeblastdb_options['publish_files']       = false
//     kraken2_build_options['publish_files']     = false
//     collapse_primers_options['publish_files']  = false
// }

// def ivar_trim_options   = modules['illumina_ivar_trim']
// ivar_trim_options.args += params.ivar_trim_noprimer ? '' : Utils.joinModuleArgs(['-e'])
// ivar_trim_options.args += params.ivar_trim_offset   ? Utils.joinModuleArgs(["-x ${params.ivar_trim_offset}"]) : ''

// def ivar_trim_sort_bam_options = modules['illumina_ivar_trim_sort_bam']
// if (params.skip_markduplicates) {
//     ivar_trim_sort_bam_options.publish_files.put('bam','')
//     ivar_trim_sort_bam_options.publish_files.put('bai','')
// }

// def spades_options   = modules['illumina_spades']
// spades_options.args += params.spades_mode ? Utils.joinModuleArgs(["--${params.spades_mode}"]) : ''

// include { INPUT_CHECK        } from '../subworkflows/local/input_check'             addParams( options: [:] )
// include { PREPARE_GENOME     } from '../subworkflows/local/prepare_genome_illumina' addParams( genome_options: publish_genome_options, index_options: publish_index_options, db_options: publish_db_options, bowtie2_build_options: bowtie2_build_options, bedtools_getfasta_options: bedtools_getfasta_options, collapse_primers_options: collapse_primers_options, snpeff_build_options: snpeff_build_options, makeblastdb_options: makeblastdb_options, kraken2_build_options: kraken2_build_options )
// include { PRIMER_TRIM_IVAR   } from '../subworkflows/local/primer_trim_ivar'        addParams( ivar_trim_options: ivar_trim_options, samtools_options: ivar_trim_sort_bam_options )
// include { VARIANTS_IVAR      } from '../subworkflows/local/variants_ivar'           addParams( ivar_variants_options: modules['illumina_ivar_variants'], ivar_variants_to_vcf_options: modules['illumina_ivar_variants_to_vcf'], tabix_bgzip_options: modules['illumina_ivar_tabix_bgzip'], tabix_tabix_options: modules['illumina_ivar_tabix_tabix'], bcftools_stats_options: modules['illumina_ivar_bcftools_stats'], ivar_consensus_options: modules['illumina_ivar_consensus'], consensus_plot_options: modules['illumina_ivar_consensus_plot'], quast_options: modules['illumina_ivar_quast'], snpeff_options: modules['illumina_ivar_snpeff'], snpsift_options: modules['illumina_ivar_snpsift'], snpeff_bgzip_options: modules['illumina_ivar_snpeff_bgzip'], snpeff_tabix_options: modules['illumina_ivar_snpeff_tabix'], snpeff_stats_options: modules['illumina_ivar_snpeff_stats'], pangolin_options: modules['illumina_ivar_pangolin'], nextclade_options: modules['illumina_ivar_nextclade'], asciigenome_options: modules['illumina_ivar_asciigenome'] )
// include { VARIANTS_BCFTOOLS  } from '../subworkflows/local/variants_bcftools'       addParams( bcftools_mpileup_options: modules['illumina_bcftools_mpileup'], quast_options: modules['illumina_bcftools_quast'], consensus_genomecov_options: modules['illumina_bcftools_consensus_genomecov'], consensus_merge_options: modules['illumina_bcftools_consensus_merge'], consensus_mask_options: modules['illumina_bcftools_consensus_mask'], consensus_maskfasta_options: modules['illumina_bcftools_consensus_maskfasta'], consensus_bcftools_options: modules['illumina_bcftools_consensus_bcftools'], consensus_plot_options: modules['illumina_bcftools_consensus_plot'], snpeff_options: modules['illumina_bcftools_snpeff'], snpsift_options: modules['illumina_bcftools_snpsift'], snpeff_bgzip_options: modules['illumina_bcftools_snpeff_bgzip'], snpeff_tabix_options: modules['illumina_bcftools_snpeff_tabix'], snpeff_stats_options: modules['illumina_bcftools_snpeff_stats'], pangolin_options: modules['illumina_bcftools_pangolin'], nextclade_options: modules['illumina_bcftools_nextclade'], asciigenome_options: modules['illumina_bcftools_asciigenome'] )
// include { ASSEMBLY_SPADES    } from '../subworkflows/local/assembly_spades'         addParams( spades_options: spades_options, bandage_options: modules['illumina_spades_bandage'], blastn_options: modules['illumina_spades_blastn'], blastn_filter_options: modules['illumina_spades_blastn_filter'], abacas_options: modules['illumina_spades_abacas'], plasmidid_options: modules['illumina_spades_plasmidid'], quast_options: modules['illumina_spades_quast'] )
// include { ASSEMBLY_UNICYCLER } from '../subworkflows/local/assembly_unicycler'      addParams( unicycler_options: modules['illumina_unicycler'], bandage_options: modules['illumina_unicycler_bandage'], blastn_options: modules['illumina_unicycler_blastn'], blastn_filter_options: modules['illumina_unicycler_blastn_filter'], abacas_options: modules['illumina_unicycler_abacas'], plasmidid_options: modules['illumina_unicycler_plasmidid'], quast_options: modules['illumina_unicycler_quast'] )
// include { ASSEMBLY_MINIA     } from '../subworkflows/local/assembly_minia'          addParams( minia_options: modules['illumina_minia'], blastn_options: modules['illumina_minia_blastn'], blastn_filter_options: modules['illumina_minia_blastn_filter'], abacas_options: modules['illumina_minia_abacas'], plasmidid_options: modules['illumina_minia_plasmidid'], quast_options: modules['illumina_minia_quast'] )

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

workflow PIPELINE {
    ch_software_versions = Channel.empty()
}

/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
    NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report, fail_mapped_reads)
    NfcoreTemplate.summary(workflow, params, log, fail_mapped_reads, pass_mapped_reads)
}

/*
========================================================================================
    THE END
========================================================================================
*/
