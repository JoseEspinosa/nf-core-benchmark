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
            log.warn "\n* params.pipeline_path has been set to a different path than the resolved using params.pipelines_dir and params.pipeline\n"
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
    // Takes the info from the pipeline yml file with the pipeline metadata and sets the corresponding benchmark
    // The information that reads from the pipeline are:
    //  - edam_operation
    //  - edam_input_data
    //  - edam_input_format
    //  - edam_output_format
    //  - edam_output_data
    //  - edam_output_format
    // With this information the benchmarker is set and it is returned in a dictionary along with the above-mentioned
    // metadata
    //
    // MAYBE ALIGNMENT SHOULD BE MODIFIED BY SOMETHING MORE GENERAL //TODO
    // TODO make it similar to the json schema parser
    // benchmarkInfo currently is a CSV but could become a DBs or something else
    public static setBenchmark (params, configYmlFile, benchmarkInfo, pipeline, input_field) {

        // TODO: colors exists as an object
        // Map colors = [:]
        // c_yellow = "\033[0;32m"
        // c_green = params.monochrome_logs ? '' : "\033[0;32m";
        // c_purple = params.monochrome_logs ? '' : "\033[0;35m";
        // c_red = params.monochrome_logs ? '' : "\033[0;31m";
        // c_reset = params.monochrome_logs ? '' : "\033[0m";
        // colors['reset']       = "\033[0m"
        // colors['dim']         = "\033[2m"
        // colors['black']       = "\033[0;30m"
        // colors['green']       = "\033[0;32m"
        // colors['yellow']      =  "\033[0;33m"
        // colors['yellow_bold'] = "\033[1;93m"
        // colors['blue']        = "\033[0;34m"
        // colors['purple']      = "\033[0;35m"
        // colors['cyan']        = "\033[0;36m"
        // colors['white']       = "\033[0;37m"
        // colors['red']         = "\033[1;91m"

        //TODO check that configYmlFile exists here or outside
        def fileYml = new File(configYmlFile)
        def yaml = new Yaml() //TODO change to use function readYml
        def pipelineConfig = yaml.load(fileYml.text)

        def topic = pipelineConfig.pipeline."$pipeline".edam_topic[0]
        def operation = pipelineConfig.pipeline."$pipeline".edam_operation[0]

        def input_data = pipelineConfig.input."$input_field".edam_data[0][0] // TODO these are hardcodes for the current example
        def input_format = pipelineConfig.input."$input_field".edam_format[0][0]
        def output_data = pipelineConfig.output.alignment.edam_data[0][0]
        def output_format = pipelineConfig.output.alignment.edam_format[0][0]


        // println """
        // INFO: pipeline ........... $pipeline
        // INFO: topic .............. $topic
        // INFO: operation .......... $operation
        // INFO: input_data ......... $input_data
        // INFO: input_format ....... $input_format
        // INFO: output_data ........ $output_data
        // INFO: output_format ...... $output_format
        // """

        def csvBenchmark = readCsv (benchmarkInfo)
        def benchmarkDict = [:]
        def i = 0

        for( row in csvBenchmark ) {
            if ( row.edam_operation == operation  &&
                row.edam_input_data == input_data &&
                row.edam_input_format == input_format &&
                row.edam_output_data == output_data &&
                row.edam_output_format == output_format ) {
                    benchmarkDict [ (row.benchmarker_priority) ] = [ benchmarker: row.benchmarker,
                                                                    operation: row.edam_operation,
                                                                    input_data: row.edam_input_data,
                                                                    input_format: row.edam_input_format,
                                                                    output_data: row.edam_output_data,
                                                                    output_format: row.edam_output_format ]
            }
        }

        def higher_priority = benchmarkDict.keySet().min()

        if ( benchmarkDict.size() == 0 ) {
            println "ERROR: No available benchmark for the selected pipeline  \"${params.pipeline}\" is not included in nf-benchmark"
            return (1) //TODO
        }
        if ( benchmarkDict.size() > 1 ) {
            // log.info "${colors.yellow}WARN: More than one possible benchmarker for \"${params.pipeline}\" pipeline benchmarker set to \"${benchmarkDict[higher_priority].benchmarker}\" (higher priority)${colors.reset}"
            println "WARN: More than one possible benchmarker for \"${params.pipeline}\" pipeline benchmarker set to \"${benchmarkDict[higher_priority].benchmarker}\" (higher priority)"
            //TODO add yellow color
            benchmarkDict = benchmarkDict [ higher_priority ]
        }

        // return benchmarkDict [ higher_priority ]
        return benchmarkDict
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
