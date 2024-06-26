process GECCO_RUN {
    tag "$meta.prefix"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gecco:0.9.8--pyhdfd78af_0':
        'biocontainers/gecco:0.9.8--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(input), path(hmm)
    path model_dir


    output:
    tuple val(meta), path("*.genes.tsv"),     optional: true, emit: genes
    tuple val(meta), path("*.features.tsv"),                  emit: features
    tuple val(meta), path("*.clusters.tsv"),  optional: true, emit: clusters
    tuple val(meta), path("*_cluster_*.gbk"), optional: true, emit: gbk
    tuple val(meta), path("*.clusters.gff"),  optional: true, emit: gff
    tuple val(meta), path("*.json"),          optional: true, emit: json
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.prefix}"
    def custom_model = model_dir ? "--model ${model_dir}" : ""
    def custom_hmm = hmm ? "--hmm ${hmm}" : ""
    """
    gecco \\
        run \\
        $args \\
        -j $task.cpus \\
        -o ./ \\
        -g ${input} \\
        $custom_model \\
        $custom_hmm

    gecco convert clusters -i ./ --format gff

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gecco: \$(echo \$(gecco --version) | cut -f 2 -d ' ' )
    END_VERSIONS
    """
}
