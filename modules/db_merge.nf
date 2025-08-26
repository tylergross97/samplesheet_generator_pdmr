process DB_MERGE {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'

    input:
    path samplesheet
    val base_dir

    output:
    path "db_merge_samplesheet.csv", emit: db_merge_samplesheet

    script:
    """
    #!/usr/bin/env python3

    import csv

    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)

    # Create the output samplesheet
    with open('db_merge_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['sample_id', 'specimen_id', 'purecn_path', 'vea_path', 'epitope_path', 'output_dir']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()

        # Process each row
        for row in rows:
            if row['sample_id'].lower() != 'germline':
                patient_id = row['patient_id']
                sample_id = row['sample_id']
                specimen_id = row['specimen_id']

                tumor_sample = f"tumor_{sample_id}_vs_normal_{sample_id}"
                purecn_path = f"${base_dir}/results/pdmr/PID_{patient_id}/purecn/purecn/{tumor_sample}_purecn_output/{tumor_sample}_variants.csv"
                vea_path = f"${base_dir}/results/pdmr/PID_{patient_id}/neo_downstream/{tumor_sample}/variants_expression_unfiltered.csv"
                epitope_path = f"${base_dir}/results/pdmr/PID_{patient_id}/epitopeprediction/predictions/{patient_id}_{sample_id}.tsv"
                output_dir = f"${base_dir}/results/pdmr/PID_{patient_id}/db_merge/"

                # Write the row
                writer.writerow({
                    'sample_id': tumor_sample,
                    'specimen_id': specimen_id,
                    'purecn_path': purecn_path,
                    'vea_path': vea_path,
                    'epitope_path': epitope_path,
                    'output_dir': output_dir
    })
    """ 
}