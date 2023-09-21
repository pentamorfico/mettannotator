process PROKKA {

    tag "${meta.prefix}"

    container "quay.io/biocontainers/prokka:1.14.6--pl526_0"

    label 'process_light'

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), file("${meta.prefix}_prokka/${meta.prefix}.gff"), emit: gff
    tuple val(meta), file("${meta.prefix}_prokka/${meta.prefix}.faa"), emit: faa
    tuple val(meta), file("${meta.prefix}_prokka/${meta.prefix}.fna"), emit: fna
    tuple val(meta), file("${meta.prefix}_prokka/${meta.prefix}.gbk"), emit: gbk
    tuple val(meta), file("${meta.prefix}_prokka/${meta.prefix}.ffn"), emit: ffn
    path "versions.yml" , emit: versions

    script:
    """
    cat ${fasta} | tr '-' ' ' > ${meta.prefix}_cleaned.fasta

    prokka ${meta.prefix}_cleaned.fasta \
    --cpus ${task.cpus} \
    --kingdom 'Bacteria' \
    --outdir ${meta.prefix}_prokka \
    --prefix ${meta.prefix} \
    --force \
    --locustag ${meta.prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prokka: \$(echo \$(prokka --version 2>&1) | sed 's/^.*prokka //')
    END_VERSIONS
    """
}