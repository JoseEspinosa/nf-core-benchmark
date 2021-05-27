//
// This file holds several functions specific to the main.nf workflow in the nf-core/viralrecon pipeline
//

import org.yaml.snakeyaml.Yaml
@Grab('com.xlson.groovycsv:groovycsv:1.0')
import static com.xlson.groovycsv.CsvParser.parseCsv

class WorkflowMain {

    //
    // Citation string for pipeline
    //
    public static String citation(workflow) {
        return "If you use ${workflow.manifest.name} for your analysis please cite:\n\n" +
            "* The pipeline\n" +
            "  https://doi.org/10.5281/zenodo.3901628\n\n" +
            "* The nf-core framework\n" +
            "  https://doi.org/10.1038/s41587-020-0439-x\n\n" +
            "* Software dependencies\n" +
            "  https://github.com/${workflow.manifest.name}/blob/master/CITATIONS.md"
    }

    //
    // Print help to screen if required
    //
    public static String help(workflow, params, log) {
        def command = "nextflow run nf-core/viralrecon --input samplesheet.csv --genome 'MN908947.3' -profile docker"
        def help_string = ''
        help_string += NfcoreTemplate.logo(workflow, params.monochrome_logs)
        help_string += NfcoreSchema.paramsHelp(workflow, params, command)
        help_string += '\n' + citation(workflow) + '\n'
        help_string += NfcoreTemplate.dashedLine(params.monochrome_logs)
        return help_string
    }

    //
    // Print parameter summary log to screen
    //
    public static String paramsSummaryLog(workflow, params, log) {
        def summary_log = ''
        summary_log += NfcoreTemplate.logo(workflow, params.monochrome_logs)
        summary_log += NfcoreSchema.paramsSummaryLog(workflow, params)
        summary_log += '\n' + citation(workflow) + '\n'
        summary_log += NfcoreTemplate.dashedLine(params.monochrome_logs)
        return summary_log
    }

    //
    // Validate parameters and print summary to screen
    //
    public static void initialise(workflow, params, log) {
        // Print help to screen if required
        if (params.help) {
            log.info help(workflow, params, log)
            System.exit(0)
        }

        // Validate workflow parameters via the JSON schema
        if (params.validate_params) {
            NfcoreSchema.validateParameters(workflow, params, log)
        }

        // Print parameter summary log to screen
        log.info paramsSummaryLog(workflow, params, log)

        // Check that conda channels are set-up correctly
        if (params.enable_conda) {
            Utils.checkCondaChannels(log)
        }

        // Check AWS batch settings
        NfcoreTemplate.awsBatch(workflow, params)

        // Check the hostnames against configured profiles
        NfcoreTemplate.hostName(workflow, params, log)

        // #DELETE
        // Check sequencing platform
        // def platformList = ['illumina', 'nanopore']
        // if (!params.public_data_ids) {
        //     if (!params.platform) {
        //         log.error "Platform not specified with e.g. '--platform illumina'. Valid options: ${platformList.join(', ')}."
        //         System.exit(1)
        //     } else if (!platformList.contains(params.platform)) {
        //         log.error "Invalid platform option: '${params.platform}'. Valid options: ${platformList.join(', ')}."
        //         System.exit(1)
        //     }
        // }
    }

    //
    // Get attribute from genome config file e.g. fasta
    //
    public static String getGenomeAttribute(params, attribute, log, primer_set='', primer_set_version=0) {
        def val = ''
        def support_link =  " The default genome config used by the pipeline can be found here:\n" +
                            "   - https://github.com/nf-core/configs/blob/master/conf/pipeline/viralrecon/genomes.config\n\n" +
                            " If you would still like to blame us please come and find us on nf-core Slack:\n" +
                            "   - https://nf-co.re/viralrecon#contributions-and-support\n" +
                            "============================================================================="
        if (params.genomes && params.genome && params.genomes.containsKey(params.genome)) {
            def genome_map = params.genomes[ params.genome ]
            if (primer_set) {
                if (genome_map.containsKey('primer_sets')) {
                    genome_map = genome_map[ 'primer_sets' ]
                    if (genome_map.containsKey(primer_set)) {
                        genome_map = genome_map[ primer_set ]
                        primer_set_version = primer_set_version.toString()
                        if (genome_map.containsKey(primer_set_version)) {
                            genome_map = genome_map[ primer_set_version ]
                        } else {
                            log.error "=============================================================================\n" +
                                " --primer_set_version '${primer_set_version}' not found!\n\n" +
                                " Currently, the available primer set version keys are: ${genome_map.keySet().join(", ")}\n\n" +
                                " Please check:\n" +
                                "   - The value provided to --primer_set_version (currently '${primer_set_version}')\n" +
                                "   - The value provided to --primer_set (currently '${primer_set}')\n" +
                                "   - The value provided to --genome (currently '${params.genome}')\n" +
                                "   - Any custom config files provided to the pipeline.\n\n" + support_link
                            System.exit(1)
                        }
                    } else {
                        log.error "=============================================================================\n" +
                            " --primer_set '${primer_set}' not found!\n\n" +
                            " Currently, the available primer set keys are: ${genome_map.keySet().join(", ")}\n\n" +
                            " Please check:\n" +
                            "   - The value provided to --primer_set (currently '${primer_set}')\n" +
                            "   - The value provided to --genome (currently '${params.genome}')\n" +
                            "   - Any custom config files provided to the pipeline.\n\n" + support_link
                        System.exit(1)
                    }
                } else {
                    log.error "=============================================================================\n" +
                        " Genome '${params.genome}' does not contain any primer sets!\n\n" +
                        " Please check:\n" +
                        "   - The value provided to --genome (currently '${params.genome}')\n" +
                        "   - Any custom config files provided to the pipeline.\n\n" + support_link
                    System.exit(1)
                }
            }
            if (genome_map.containsKey(attribute)) {
                val = genome_map[ attribute ]
            }
        }
        return val
    }

    //
    // Get benchmarker for the pipeline
    //
    public static String getBenchmarker(workflow, params, log) {
        def benchmarker = ''

        if (!params.path_to_pipelines || !params.pipeline) {
            log.error ("ERROR HERE")//TODO
        }

        def yaml_file = "${params.path_to_pipelines}/" + "${params.pipeline}/" + 'meta.yml'
        Yaml parser = new Yaml()
        def pipeline_meta = parser.load((yaml_file as File).text)
        def topic = pipeline_meta.pipeline."$params.pipeline".edam_topic[0]
        def operation = pipeline_meta.pipeline."$params.pipeline".edam_operation[0]
        def input_field = pipeline_meta.input[0][0].keySet()[0]
        def input_data = pipeline_meta.input."$input_field".edam_data[0][0] // TODO these are hardcodes for the current example
        def input_format = pipeline_meta.input."$input_field".edam_format[0][0]
        def output_data = pipeline_meta.output.alignment.edam_data[0][0]
        def output_format = pipeline_meta.output.alignment.edam_format[0][0]

        log.info """
        INFO: pipeline ........... $params.pipeline
        INFO: topic .............. $topic
        INFO: operation .......... $operation
        INFO: input_data ......... $input_data
        INFO: input_format ....... $input_format
        INFO: output_data ........ $output_data
        INFO: output_format ...... $output_format
        """

        // def csv_file = new File ("${workflow.projectDir}/assets/methods2benchmark.csv")
        // def csv_benchmark = csv_file.getText('utf-8')
        def file_csv       = new File("${workflow.projectDir}/assets/methods2benchmark.csv")
        def csv_benchmark = parseCsv(file_csv.text, autoDetect:true)

        def benchmark_dict = [:]
        def i = 0


        for( row in csv_benchmark ) {
            if (row.edam_operation     == operation   &&
                row.edam_input_data    == input_data   &&
                row.edam_input_format  == input_format &&
                row.edam_output_data   == output_data  &&
                row.edam_output_format == output_format ) {
                    benchmark_dict [ (row.benchmarker_priority) ] = [ benchmarker: row.benchmarker,
                        operation: row.edam_operation,
                        input_data: row.edam_input_data,
                        input_format: row.edam_input_format,
                        output_data: row.edam_output_data,
                        output_format: row.edam_output_format ]
            }
        }

        def higher_priority = benchmark_dict.keySet().min()

        if ( benchmark_dict.size() == 0 ) exit 1, "Error: No available benchmark for the selected pipeline  \"${params.pipeline}\" is not included in nf-benchmark"

        if ( benchmark_dict.size() > 1 ) {
            log.info "WARN: More than one possible benchmarker for \"${params.pipeline}\" pipeline benchmarker set to \"${benchmark_dict[higher_priority].benchmarker}\" (higher priority)"
            benchmark_dict = benchmark_dict [ higher_priority ]
        }

        return benchmark_dict.benchmarker
    }
}
