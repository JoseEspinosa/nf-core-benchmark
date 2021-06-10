//
// This file holds several functions specific to the workflow/pipeline.nf in the nf-core/benchmark pipeline
//

import org.yaml.snakeyaml.Yaml
@Grab('com.xlson.groovycsv:groovycsv:1.0')
import static com.xlson.groovycsv.CsvParser.parseCsv

class WorkflowPipeline {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log, valid_params) {

        // Generic parameter validation
        if (!params.pipeline) {
            log.error ("Pipeline to be included not specified with e.g. '--pipeline your_pipeline' or via a detectable config file.")
            System.exit(1)
        }
        if (!params.pipelines_dir) {
            log.error ("Pipeline to be included not specified with e.g. '--pipelines_dir ./path_to_pipelines' or via a detectable config file.")
            System.exit(1)
        }
        // Check equivalence between params.pipeline_path and the path set by pipelines_dir + pipeline
        def main_script = 'main.nf'
        def pipeline_main = "${params.pipelines_dir}/${params.pipeline}/" + main_script
        if (params.pipeline_path != pipeline_main) {
            log.warn ("\n* params.pipeline_path has been set to a different path than the resolved using params.pipelines_dir and params.pipeline:\n" +
                "* params.pipeline_path   = ${params.pipeline_path}\n" +
                "* pipeline resolved path = ${pipeline_main}")
        }
    }

    // USE CONFIGURATION FILES FOR SETTING EXECUTION

    //
    // Function to read yml file
    //
    public static Map readYml (path) {
        def file_yml = new File(path)
        def yaml = new Yaml()
        def content = yaml.load(file_yml.text)

        return content

    }

    //
    // Function to read csv file
    //
    public static Iterator readCsv (path) {
        def file_csv = new File(path)
        def content = parseCsv(file_csv.text, autoDetect:true)

        return content
    }

    //
    // Function to return the parameter used by the pipeline/benchmarker as input
    //
    public static String setInputParam (path) {

        def bench_bool = 'input_nfb' // TODO check this

        def pipelineConfigYml = readYml (path)

        // Get all input parameters
        def input_param = pipelineConfigYml.input.input_param[0][0]
        def map_input = pipelineConfigYml.input[0][0]

        // Checks whether yml has the input_nfb field check to true (input nf-benchmark)
        map_input.each{
            // log.info "key_________: ${it.key}" // #del
            if (map_input[it.key]['input_nfb']) {
                input_param = it.key
            }
        }
        return input_param
    }
}
