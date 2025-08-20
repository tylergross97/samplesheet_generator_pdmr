process PURECN {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'

    input:
    path samplesheet
    val base_dir

    output:
    path "purecn_samplesheet.csv", emit: purecn_samplesheet

    script:
    """
    #!/usr/bin/env python3

    import csv

    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)

    # Create the output samplesheet
    with open('purecn_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['sample_id', 'tumor_cnr', 'tumor_cns', 'vcf']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()

        # Process each row
        for row in rows:
            if row['sample_id'].lower() != 'germline':
                patient_id = row['patient_id']
                sample_id = row['sample_id']

                tumor_sample = f"tumor_{sample_id}_vs_normal_{sample_id}"
                tumor_cnr = f"${base_dir}/results/pdmr/PID_{patient_id}/sarek/variant_calling/cnvkit/{tumor_sample}/tumor_{sample_id}.cnr"
                tumor_cns = f"${base_dir}/results/pdmr/PID_{patient_id}/sarek/variant_calling/cnvkit/{tumor_sample}/tumor_{sample_id}.cns"
                vcf = f"${base_dir}/results/pdmr/PID_{patient_id}/sarek/variant_calling/mutect2/{tumor_sample}/{tumor_sample}.mutect2.filtered.vcf.gz"

                # Write the row
                writer.writerow({
                    'sample_id': tumor_sample,
                    'tumor_cnr': tumor_cnr,
                    'tumor_cns': tumor_cns,
                    'vcf': vcf
    })
    """
}