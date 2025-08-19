process HLATYPING {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'

    input:
    path samplesheet
    val base_dir

    output:
    path "hlatyping_samplesheet.csv", emit: hlatyping_samplesheet

    script:
    """
    #!/usr/bin/env python3

    import csv

    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)

    # Create the output samplesheet
    with open('hlatyping_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['sample', 'fastq_1', 'fastq_2', 'seq_type']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()

        # Process each row
        for row in rows:
            if row['sample_id'].lower() == 'germline':
                patient_id = row['patient_id']
                germline_version = row['germline_version']

                # Create the sample name
                patient_id = f"PID_{patient_id}"
                germline_version = f"v_{germline_version}"
                fastq_1_path = f"${base_dir}/data/pdmr/PID_{patient_id}/normal_wes/{patient_id}~{germline_version}~germlineWES.R1.fastq.gz"
                fastq_2_path = f"${base_dir}/data/pdmr/PID_{patient_id}/normal_wes/{patient_id}~{germline_version}~germlineWES.R2.fastq.gz"
                seq_type = "dna"

                # Write the row
                writer.writerow({
                    'sample': patient_id,
                    'fastq_1': fastq_1_path,
                    'fastq_2': fastq_2_path,
                    'seq_type': seq_type
    })
    """
}