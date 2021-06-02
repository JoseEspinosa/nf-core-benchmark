//
// This file holds several functions specific to the workflow/benchmark.nf in the nf-core/benchmark pipeline
//

class WorkflowBenchmark {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log, valid_params) {

        // Generic parameter validation
        if (!params.benchmarkers_dir) {
            log.error ("Benchmarker folder not specified with e.g. '--benchmarkers_dir ./path_to_benchmarkers' or via a detectable config file.")
            System.exit(1)
        }

        if (!params.benchmarker) {
            log.error ("Benchmarker to be included not specified with e.g. '--benchmarker your_pipeline' or via a detectable config file.")
            System.exit(1)
        }

        def main_script = 'main.nf'
        def benchmarker_main = "${params.benchmarker_dir}/${params.benchmarker}/" + main_script
        if (params.benchmarker_path != benchmarker_main) {
            log.warn "\n* params.benchmarker_path has been set to a different path than the resolved using params.benchmarker_dir and params.benchmarker\n"
        }
    }
}
