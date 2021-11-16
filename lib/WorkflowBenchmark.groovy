//
// This file holds several functions specific to the workflow/benchmark.nf in the nf-core/benchmark pipeline
//

class WorkflowBenchmark {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {
        genomeExistsError(params, log)

        if (!params.fasta) {
            log.error "Genome fasta file not specified with e.g. '--fasta genome.fa' or via a detectable config file."
            System.exit(1)
        }
    }
        // Generic parameter validation
        if (!params.benchmarkers_dir) {
            log.error ("Benchmarker folder not specified with e.g. '--benchmarkers_dir ./path_to_benchmarkers' or via a detectable config file.")
            System.exit(1)
        }

        if (!params.benchmarker) {
            log.error ("Benchmarker to be included not specified with e.g. '--benchmarker your_pipeline' or via a detectable config file.")
            System.exit(1)
        }

        // if (params.params.benchmarker_dir && params.benchmarker) {
        //         if (!params.benchmarker_path) {

        //         }
        // }

        def main_script = 'main.nf'
        def benchmarker_main = "${params.benchmarker_dir}/${params.benchmarker}/" + main_script
        if (params.benchmarker_path != benchmarker_main) {
            log.warn "\n* params.benchmarker_path has been set to a different path than the resolved using params.benchmarker_dir and params.benchmarker\n" +
                "* params.benchmarker_path   = ${params.benchmarker_path}\n" +
                "* benchmarker resolved path = ${benchmarker_main}")
    //
    // Get workflow summary for MultiQC
    //
    public static String paramsSummaryMultiqc(workflow, summary) {
        String summary_section = ''
        for (group in summary.keySet()) {
            def group_params = summary.get(group)  // This gets the parameters of that particular group
            if (group_params) {
                summary_section += "    <p style=\"font-size:110%\"><b>$group</b></p>\n"
                summary_section += "    <dl class=\"dl-horizontal\">\n"
                for (param in group_params.keySet()) {
                    summary_section += "        <dt>$param</dt><dd><samp>${group_params.get(param) ?: '<span style=\"color:#999999;\">N/A</a>'}</samp></dd>\n"
                }
                summary_section += "    </dl>\n"
            }
        }

        String yaml_file_text  = "id: '${workflow.manifest.name.replace('/','-')}-summary'\n"
        yaml_file_text        += "description: ' - this information is collected when the pipeline is started.'\n"
        yaml_file_text        += "section_name: '${workflow.manifest.name} Workflow Summary'\n"
        yaml_file_text        += "section_href: 'https://github.com/${workflow.manifest.name}'\n"
        yaml_file_text        += "plot_type: 'html'\n"
        yaml_file_text        += "data: |\n"
        yaml_file_text        += "${summary_section}"
        return yaml_file_text
    }

    //
    // Exit pipeline if incorrect --genome key provided
    //
    private static void genomeExistsError(params, log) {
        if (params.genomes && params.genome && !params.genomes.containsKey(params.genome)) {
            log.error "=============================================================================\n" +
                "  Genome '${params.genome}' not found in any config files provided to the pipeline.\n" +
                "  Currently, the available genome keys are:\n" +
                "  ${params.genomes.keySet().join(", ")}\n" +
                "==================================================================================="
            System.exit(1)
        }
    }
}
