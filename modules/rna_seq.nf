process RNA_SEQ {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'
    
    input:
    path samplesheet
    val base_dir
    
    output:
    path "rna_seq_samplesheet.csv",  emit: rnaseq_samplesheet
    
    script:
    """
    #!/usr/bin/env python3
    
    import csv
    
    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)
    
    # Create the output samplesheet
    with open('rna_seq_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['sample', 'fastq_1', 'fastq_2', 'strandedness']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()
        
        # Process each row
        for row in rows:
            patient_id = row['patient_id']
            sample_id = row['sample_id']
            specimen_id = row['specimen_id']
            version = row['rnaseq_version']
            
            # Skip germline samples
            if sample_id.lower() == "germline":
                continue
            
            # Create the sample name
            sample_name = f"PID_{patient_id}_{sample_id}"
            
            # Conditionally build paths based on sample_id
            if sample_id == "ORIGINATOR":
                # ORIGINATOR samples use data/pdmr path
                fastq_1_path = f"${base_dir}/data/pdmr/PID_{patient_id}/tumor_rnaseq/{sample_id}/{patient_id}~{specimen_id}~{sample_id}~v{version}~RNASEQ.R1.fastq.gz"
                fastq_2_path = f"${base_dir}/data/pdmr/PID_{patient_id}/tumor_rnaseq/{sample_id}/{patient_id}~{specimen_id}~{sample_id}~v{version}~RNASEQ.R2.fastq.gz"
            else:
                # Non-ORIGINATOR samples use nextflow_xengsort/results/pdmr path
                fastq_1_path = f"${base_dir}/nextflow_xengsort/results/pdmr/PID_{patient_id}/xengsort/{patient_id}~{specimen_id}~{sample_id}_RNAseq-graft.1.fq.gz"
                fastq_2_path = f"${base_dir}/nextflow_xengsort/results/pdmr/PID_{patient_id}/xengsort/{patient_id}~{specimen_id}~{sample_id}_RNAseq-graft.2.fq.gz"
            
            # Write the row
            writer.writerow({
                'sample': sample_name,
                'fastq_1': fastq_1_path,
                'fastq_2': fastq_2_path,
                'strandedness': 'auto'
            })
    """
}