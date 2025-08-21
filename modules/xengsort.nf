process XENGSORT {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'

    input:
    path samplesheet
    val base_dir

    output:
    path "xengsort_samplesheet.csv", emit: xengsort_samplesheet

    script:
    """
    #!/usr/bin/env python3

    import csv

    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)

    # Create the output samplesheet
    with open('xengsort_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['sample', 'fastq1', 'fastq2']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)

        # Write header
        writer.writeheader()

        # Process each row
        for row in rows:
            if row['sample_id'].lower() not in ['germline', 'originator']:
                patient_id = row['patient_id']
                sample_id = row['sample_id']
                specimen_id = row['specimen_id']
                rnaseq_version = row['rnaseq_version']
                wes_version = row['wes_version']

                # RNAseq row
                sample_rna = f"{patient_id}~{specimen_id}~{sample_id}_RNAseq"
                fastq1_rna = f"${base_dir}/data/pdmr/PID_{patient_id}/tumor_rnaseq/{patient_id}~{specimen_id}~{sample_id}~v{rnaseq_version}~RNASEQ.R1.FASTQ.gz"
                fastq2_rna = f"${base_dir}/data/pdmr/PID_{patient_id}/tumor_rnaseq/{patient_id}~{specimen_id}~{sample_id}~v{rnaseq_version}~RNASEQ.R2.FASTQ.gz"

                writer.writerow({
                    'sample': sample_rna,
                    'fastq1': fastq1_rna,
                    'fastq2': fastq2_rna
                })
    
                # WES row
                sample_wes = f"{patient_id}~{specimen_id}~{sample_id}_WES"
                fastq1_wes = f"${base_dir}/data/pdmr/PID_{patient_id}/tumor_wes/{sample_id}/{patient_id}~{specimen_id}~{sample_id}~v{wes_version}~WES.R1.FASTQ.gz"
                fastq2_wes = f"${base_dir}/data/pdmr/PID_{patient_id}/tumor_wes/{sample_id}/{patient_id}~{specimen_id}~{sample_id}~v{wes_version}~WES.R2.FASTQ.gz"

                writer.writerow({
                    'sample': sample_wes,
                    'fastq1': fastq1_wes,
                    'fastq2': fastq2_wes
                })
    """
}