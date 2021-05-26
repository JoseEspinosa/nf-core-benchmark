process MEAN_SCORE {
    tag { 'benchmark_mean' }
    publishDir "${params.outdir}/tcoffee"
    container 'quay.io/biocontainers/r-base:3.5.0'

    // conda (params.enable_conda ? 'bioconda::r-base=3.5.0' : null)
    // if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
    //     container 'https://depot.galaxyproject.org/singularity/r-base:3.5.0'
    // } else {
    //     container 'quay.io/biocontainers/r-base:3.5.0'
    // }

    input:
    file (scores)

    output:
    stdout()

    script:
    """
    #!/usr/bin/env Rscript

    cat(mean(read.csv (\"$scores\", header=F)\$V1))
    """
}
