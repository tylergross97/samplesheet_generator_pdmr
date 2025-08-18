process SAREK {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'

    input:
    path samplesheet
    val base_dir

    output:
    path "sarek_samplesheet.csv", emit: sarek_samplesheet

    script:
    """
    #!/usr/bin/env python3
    
    import csv
    
    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)
    
    # Create the output samplesheet
    with open('sarek_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['patient', 'sex', 'status', 'sample', 'lane', 'fastq_1', 'fastq_2']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()
        
        # Group samples by patient_id to handle tumor-normal pairing
        patients = {}
        for row in rows:
            patient_id = row['patient_id']
            sample_id = row['sample_id']
            
            if patient_id not in patients:
                patients[patient_id] = {'normal': [], 'tumor': []}
            
            # Determine status based on sample_id
            if sample_id.lower() == 'germline':
                patients[patient_id]['normal'].append(row)
            else:
                patients[patient_id]['tumor'].append(row)
        
        # Process each patient
        for patient_id, samples in patients.items():
            # Get the normal and tumor samples
            normal_samples = samples['normal']
            tumor_samples = samples['tumor']
            
            # For each tumor sample, create a tumor-normal pair (or tumor-only if no normal)
            for tumor_row in tumor_samples:
                patient_name = f"PID_{patient_id}_{tumor_row['sample_id']}"
                
                # Convert sex format (male/female -> XY/XX)
                sex_code = 'XY' if tumor_row['sex'].lower() == 'male' else 'XX'
                
                # Write normal sample (status=0) - paired with this tumor (if available)
                if normal_samples:
                    normal_row = normal_samples[0]  # Use first (should be only) normal sample
                    normal_sample_name = f"normal_{tumor_row['sample_id']}"
                    # Use the wes_version from the normal sample data
                    normal_fastq_1 = f"${base_dir}/data/pdmr/PID_{patient_id}/normal_wes/{patient_id}~{normal_row['wes_version']}~germlineWES.R1.fastq.gz"
                    normal_fastq_2 = f"${base_dir}/data/pdmr/PID_{patient_id}/normal_wes/{patient_id}~{normal_row['wes_version']}~germlineWES.R2.fastq.gz"
                    
                    writer.writerow({
                        'patient': patient_name,
                        'sex': sex_code,
                        'status': '0',  # normal = 0
                        'sample': normal_sample_name,
                        'lane': '1',
                        'fastq_1': normal_fastq_1,
                        'fastq_2': normal_fastq_2
                    })
                
                # Always write tumor sample (status=1) - regardless of whether normal exists
                tumor_sample_name = f"tumor_{tumor_row['sample_id']}"
                
                # Determine paths based on sample_id
                if tumor_row['sample_id'] == "ORIGINATOR":
                    # ORIGINATOR samples use data/pdmr path with WES files
                    tumor_fastq_1 = f"${base_dir}/data/pdmr/PID_{patient_id}/tumor_wes/{tumor_row['sample_id']}/{patient_id}~{tumor_row['specimen_id']}-R~{tumor_row['sample_id']}~{tumor_row['wes_version']}~WES.R1.fastq.gz"
                    tumor_fastq_2 = f"${base_dir}/data/pdmr/PID_{patient_id}/tumor_wes/{tumor_row['sample_id']}/{patient_id}~{tumor_row['specimen_id']}-R~{tumor_row['sample_id']}~{tumor_row['wes_version']}~WES.R2.fastq.gz"
                else:
                    # Non-ORIGINATOR samples use nextflow_xengsort/results/pdmr path
                    tumor_fastq_1 = f"${base_dir}/nextflow_xengsort/results/pdmr/PID_{patient_id}/xengsort/{patient_id}~{tumor_row['specimen_id']}-R~{tumor_row['sample_id']}_WES-graft.1.fq.gz"
                    tumor_fastq_2 = f"${base_dir}/nextflow_xengsort/results/pdmr/PID_{patient_id}/xengsort/{patient_id}~{tumor_row['specimen_id']}-R~{tumor_row['sample_id']}_WES-graft.2.fq.gz"
                
                writer.writerow({
                    'patient': patient_name,
                    'sex': sex_code,
                    'status': '1',  # tumor = 1
                    'sample': tumor_sample_name,
                    'lane': '1',
                    'fastq_1': tumor_fastq_1,
                    'fastq_2': tumor_fastq_2
                })
            
            # Handle standalone normal samples (no corresponding tumor)
            if not tumor_samples:
                for normal_row in normal_samples:
                    patient_name = f"PID_{patient_id}_{normal_row['sample_id']}"
                    sex_code = 'XY' if normal_row['sex'].lower() == 'male' else 'XX'
                    normal_sample_name = f"normal_{normal_row['sample_id']}"
                    # Use the wes_version from the normal sample data
                    normal_fastq_1 = f"${base_dir}/data/pdmr/PID_{patient_id}/normal_wes/{patient_id}~{normal_row['wes_version']}~germlineWES.R1.fastq.gz"
                    normal_fastq_2 = f"${base_dir}/data/pdmr/PID_{patient_id}/normal_wes/{patient_id}~{normal_row['wes_version']}~germlineWES.R2.fastq.gz"
                    
                    writer.writerow({
                        'patient': patient_name,
                        'sex': sex_code,
                        'status': '0',  # normal = 0
                        'sample': normal_sample_name,
                        'lane': '1',
                        'fastq_1': normal_fastq_1,
                        'fastq_2': normal_fastq_2
                    })
    """
}