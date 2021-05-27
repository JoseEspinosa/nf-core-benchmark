/*
 * Workflow to run bali_score
 * Pipelines could be complex with several steps, thus I need to declare here all the modules and the logic of the
 * pipeline but not the benchmark steps
 * This workflow should enclose all the steps to perform the benchmark
 */

params.reference = "/Users/jaespinosa/git/nf-benchmark/reference_dataset/BBA0001.xml" //TODO assign like in nf-benchmark

include { REFORMAT as REFORMAT_TO_BALI_SCORE }  from "${moduleDir}/modules/reformat_to_bali_score.nf"
include { BALI_SCORE as BALI_SCORE_MODULE } from "${moduleDir}/modules/bali_score.nf"

// TODO implement logic to check that params.reference is set, ambigous error otherwise (Missing `fromPath` parameter)
// println "-----------------------reference: $params.reference ===============\n"

// Set sequences channel
reference_ch = Channel.fromPath( params.reference, checkIfExists: true ).map { item -> [ item.baseName, item ] }

// Run the workflow
workflow BALI_SCORE {
    take:
    target_aln

    main:
    target_aln
    .join ( reference_ch, by: [0] )
      .ifEmpty { error "Cannot find any reference matching alignment for benchmarking" }
      .set { target_and_ref }

    // REFORMAT_TO_BENCHMARK (target_and_ref)
    REFORMAT_TO_BALI_SCORE (target_and_ref)  \
      | BALI_SCORE_MODULE

    emit:
    BALI_SCORE_MODULE.out
    // REFORMAT_TO_BENCHMARK.out
}

workflow {
  BALI_SCORE()
}
