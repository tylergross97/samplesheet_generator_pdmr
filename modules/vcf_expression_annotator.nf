process VCF_EXPRESSION_ANNOTATOR {
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'
    publishDir params.outdir_base, mode: 'copy'

    input:
    path samplesheet
    val base_dir

    output:
    path "vcf_expression_annotator_samplesheet.csv", emit: vcf_expression_annotator_samplesheet

    script:
    """
    #!/usr/bin/env python3

    import csv

    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)

    # Create the output samplesheet
    with open('vcf_expression_annotator_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['sample_id', 'vcf_path', 'vcf_tumor_sample']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()

        # Process each row
        for row in rows:
            if row['sample_id'].lower() != 'germline':
                patient_id = row['patient_id']
                sample_id = row['sample_id']

                # Create the sample name
                vcf_tumor_sample = f"PID_{patient_id}_{sample_id}_tumor_{sample_id}"
                vcf_path = f"${base_dir}/results/pdmr/PID_{patient_id}/sarek/annotation/mutect2/tumor_{sample_id}_vs_normal_{sample_id}/tumor_{sample_id}_vs_normal_{sample_id}.mutect2.filtered_VEP.ann.vcf.gz"

                # Write the row
                writer.writerow({
                    'sample_id': sample_id,
                    'vcf_path': vcf_path,
                    'vcf_tumor_sample': vcf_tumor_sample
    })
    """
}