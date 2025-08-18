process RNA_SEQ {
    publishDir params.outdir_base, mode: 'copy'
    
    input:
    path samplesheet
    val base_dir
    
    output:
    path "rna_seq_samplesheet.csv",  emit: rnaseq_samplesheet
    
    script:
    """
    #!/usr/bin/env bash
    
    # Create header
    echo "sample,fastq_1,fastq_2,strandedness" > rna_seq_samplesheet.csv
    
    # Process each line (skip header)
    tail -n +2 ${samplesheet} | while IFS=',' read -r patient_id sample_id specimen_id version; do
        # Remove any quotes or whitespace
        patient_id=\$(echo "\$patient_id" | tr -d '"' | xargs)
        sample_id=\$(echo "\$sample_id" | tr -d '"' | xargs)
        specimen_id=\$(echo "\$specimen_id" | tr -d '"' | xargs)
        version=\$(echo "\$version" | tr -d '"' | xargs)
        
        # Create sample name
        sample_name="PID_\${patient_id}_\${sample_id}"
        
        # Conditionally build paths based on sample_id
        if [ "\$sample_id" = "ORIGINATOR" ]; then
            # ORIGINATOR samples use data/pdmr path
            fastq_1="${base_dir}/data/pdmr/PID_\${patient_id}/tumor_rnaseq/\${patient_id}~\${specimen_id}-R~\${sample_id}~\${version}~RNASEQ.R1.fastq.gz"
            fastq_2="${base_dir}/data/pdmr/PID_\${patient_id}/tumor_rnaseq/\${patient_id}~\${specimen_id}-R~\${sample_id}~\${version}~RNASEQ.R2.fastq.gz"
        else
            # Non-ORIGINATOR samples use nextflow_xengsort/results/pdmr path
            fastq_1="${base_dir}/nextflow_xengsort/results/pdmr/PID_\${patient_id}/xengsort/\${patient_id}~\${specimen_id}-R~\${sample_id}_RNAseq-graft.1.fq.gz"
            fastq_2="${base_dir}/nextflow_xengsort/results/pdmr/PID_\${patient_id}/xengsort/\${patient_id}~\${specimen_id}-R~\${sample_id}_RNAseq-graft.2.fq.gz"
        fi
        
        # Write to output file
        echo "\${sample_name},\${fastq_1},\${fastq_2},auto" >> rna_seq_samplesheet.csv
    done
    """
}