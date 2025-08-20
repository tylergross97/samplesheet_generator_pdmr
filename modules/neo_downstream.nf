process NEO_DOWNSTREAM {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'

    input:
    path samplesheet
    val base_dir

    output:
    path "neo_downstream_samplesheet.csv", emit: neo_downstream_samplesheet

    script:
    """
    #!/usr/bin/env python3

    import csv

    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)

    # Create the output samplesheet
    with open('neo_downstream_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['sample_id', 'variants_expression', 'binding_predictions', 'outdir']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()

        # Process each row
        for row in rows:
            if row['sample_id'].lower() != 'germline':
                patient_id = row['patient_id']
                sample_id = row['sample_id']

                tumor_sample = f"tumor_{sample_id}_vs_normal_{sample_id}"
                variants_expression = f"${base_dir}/results/pdmr/PID_{patient_id}/sarek/vcf_expression_annotator/clean_vcf/PID_{patient_id}_{sample_id}_neoantigen.csv"
                binding_predictions = f"${base_dir}/results/pdmr/PID_{patient_id}/epitopeprediction/predictions/PID_{patient_id}_{sample_id}.tsv"
                outdir = f"${base_dir}/results/pdmr/{patient_id}/neo_downstream/"

                # Write the row
                writer.writerow({
                    'sample_id': tumor_sample,
                    'variants_expression': variants_expression,
                    'binding_predictions': binding_predictions,
                    'outdir': outdir
    })
    """
} 