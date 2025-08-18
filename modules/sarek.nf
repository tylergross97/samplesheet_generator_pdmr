process SAREK {
    publishDir params.outdir_base, mode: 'copy'

    input:
    path samplesheet
    val base_dir

    output:
    path "sarek_samplesheet.csv", emit: sarek_samplesheet

    script:
    """
    #!/usr/bin/env bash

    # Skip header and process each line
    tail -n +2 ${samplesheet} | while IFS=',' read -r patient_id sample_id specimen_id version sex status lane; do
        # Remove quotes and whitespace
        patient_id=\$(echo "\$patient_id" | tr -d '"' | xargs)
        sample_id=\$(echo "\$sample_id" | tr -d '"' | xargs)
        specimen_id=\$(echo "\$specimen_id" | tr -d '"' | xargs)
        version=\$(echo "\$version" | tr -d '"' | xargs)
        sex=\$(echo "\$sex" | tr -d '"' | xargs)
        status=\$(echo "\$status" | tr -d '"' | xargs)
        lane=\$(echo "\$lane" | tr -d '"' | xargs)

        # Build sample name
        sample="PID_\${patient_id}_\${sample_id}"

        # Build fastq paths (customize as needed)
        fastq_1="\${input_base}/nextflow_xengsort/results/pdmr/PID_\${patient_id}/xengsort/\${patient_id}~\${specimen_id}-R~\${sample_id}_RNAseq-graft.1.fq.gz"
        fastq_2="\${input_base}/nextflow_xengsort/results/pdmr/PID_\${patient_id}/xengsort/\${patient_id}~\${specimen_id}-R~\${sample_id}_RNAseq-graft.2.fq.gz"

        # Write row
        echo "\${patient_id},\${sex},\${status},\${sample},\${lane},\${fastq_1},\${fastq_2}" >> new_samplesheet.csv
    done
    """
}