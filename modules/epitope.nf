process EPITOPE {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'

    input:
    path samplesheet
    val base_dir

    output:
    path "epitope_samplesheet.csv", emit: epitope_samplesheet

    script:
    """
    #!/usr/bin/env python3

    import csv

    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)

    # Create the output samplesheet
    with open('epitope_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['sample', 'alleles', 'mhc_class', 'filename']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()

        # Process each row
        for row in rows:
            if row['sample_id'].lower() != 'germline':
                patient_id = row['patient_id']
                sample_id = row['sample_id']
                sample_name = f"{patient_id}_{sample_id}"
                alleles = row['hla']
                mhc_class = 'I'
                vcf_path = f"${base_dir}/results/pdmr/{patient_id}/vcf_expreession_annotator/clean_vcf/{patient_id}_{sample_id}.clean.vcf.gz"

                # Write the row
                writer.writerow({
                    'sample': sample_name,
                    'alleles': alleles,
                    'mhc_class': mhc_class,
                    'filename': vcf_path
    })
    """  
}