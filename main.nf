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
    GENOME PARAMETER VALUES
========================================================================================
*/

// def primer_set         = ''
// def primer_set_version = 0
// if (!params.public_data_ids && params.platform == 'illumina' && params.protocol == 'amplicon') {
//     primer_set         = params.primer_set
//     primer_set_version = params.primer_set_version
// } else if (!params.public_data_ids && params.platform == 'nanopore') {
//     primer_set          = 'artic'
//     primer_set_version  = params.primer_set_version
//     params.artic_scheme = WorkflowMain.getGenomeAttribute(params, 'scheme', log, primer_set, primer_set_version)
// }

// params.fasta         = WorkflowMain.getGenomeAttribute(params, 'fasta'     , log, primer_set, primer_set_version)
// params.gff           = WorkflowMain.getGenomeAttribute(params, 'gff'       , log, primer_set, primer_set_version)
// params.bowtie2_index = WorkflowMain.getGenomeAttribute(params, 'bowtie2'   , log, primer_set, primer_set_version)
// params.primer_bed    = WorkflowMain.getGenomeAttribute(params, 'primer_bed', log, primer_set, primer_set_version)


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

workflow  NFCORE_BENCHMARK {
    include { PIPELINE } from './workflows/pipeline' //addParams( summary_params: summary_params )
    PIPELINE ()
}

workflow {
  NFCORE_BENCHMARK ()
}

////////////////////////////////////////////////////
/* --                  THE END                 -- */
////////////////////////////////////////////////////