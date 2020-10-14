// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process UNTAR {
    tag "$archive"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    container "biocontainers/biocontainers:v1.2.0_cv1"
    
    conda (params.conda ? "conda-forge::sed=4.7" : null)
    
    input:
    path archive
    
    output:
    path "$untar"       , emit: untar
    path "*.version.txt", emit: version
    
    script:
    def software = getSoftwareName(task.process) 
    untar        = archive.toString() - '.tar.gz'
    """
    tar -xzvf $options.args $archive
    echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//' > ${software}.version.txt
    """
}
