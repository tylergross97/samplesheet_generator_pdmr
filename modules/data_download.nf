process DATA_DOWNLOAD {
    publishDir params.outdir_base, mode: 'copy'
    container 'community.wave.seqera.io/library/python:3.13.0--a025ad9838d75455'

    input:
    path samplesheet
    val base_dir

    output:
    path "data_download_samplesheet.csv", emit: data_download_samplesheet

    script:
    """
    #!/usr/bin/env python3

    import csv

    # Read the input CSV
    with open('${samplesheet}', 'r') as infile:
        reader = csv.DictReader(infile)
        rows = list(reader)

    # Create the output samplesheet
    with open('data_download_samplesheet.csv', 'w', newline='') as outfile:
        fieldnames = ['patient_id', 'sample_id', 'tumor_wes_1', 'tumor_wes_2', 'tumor_rnaseq_1', 'tumor_rnaseq_2', 'normal_wes_1', 'normal_wes_2']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)

        # Write header
        writer.writeheader()

        # Process each row
        for row in rows:
            if row['sample_id'].lower() != 'germline':
                patient_id = row['patient_id']
                specimen_id = row['specimen_id']
                sample_id = row['sample_id']
                wes_version = row['wes_version']
                rnaseq_version = row['rnaseq_version']

                tumor_wes_1 = f"https://pdmdb.cancer.gov/pdm/{patient_id}~{specimen_id}~{sample_id}~v{wes_version}~WES.R1.FASTQ.gz"
                tumor_wes_2 = f"https://pdmdb.cancer.gov/pdm/{patient_id}~{specimen_id}~{sample_id}~v{wes_version}~WES.R2.FASTQ.gz"
                tumor_rnaseq_1 = f"https://pdmdb.cancer.gov/pdm/{patient_id}~{specimen_id}~{sample_id}~v{rnaseq_version}~RNASEQ.R1.FASTQ.gz"
                tumor_rnaseq_2 = f"https://pdmdb.cancer.gov/pdm/{patient_id}~{specimen_id}~{sample_id}~v{rnaseq_version}~RNASEQ.R2.FASTQ.gz"

                writer.writerow({
                    'patient_id': patient_id,
                    'sample_id': sample_id,
                    'tumor_wes_1': tumor_wes_1,
                    'tumor_wes_2': tumor_wes_2,
                    'tumor_rnaseq_1': tumor_rnaseq_1,
                    'tumor_rnaseq_2': tumor_rnaseq_2,
                    'normal_wes_1': '',
                    'normal_wes_2': ''
                })
            else:
                patient_id = row['patient_id']
                specimen_id = row['specimen_id']
                sample_id = row['sample_id']
                germline_version = row['germline_version']

                normal_wes_1 = f"https://pdmdb.cancer.gov/pdm/{patient_id}~v{germline_version}~germlineWES.R1.FASTQ.gz"
                normal_wes_2 = f"https://pdmdb.cancer.gov/pdm/{patient_id}~v{germline_version}~germlineWES.R2.FASTQ.gz"
                
                writer.writerow({
                    'patient_id': patient_id,
                    'sample_id': sample_id,
                    'tumor_wes_1': '',
                    'tumor_wes_2': '',
                    'tumor_rnaseq_1': '',
                    'tumor_rnaseq_2': '',
                    'normal_wes_1': normal_wes_1,
                    'normal_wes_2': normal_wes_2
                })
    """

    stub:
    """
    #!/usr/bin/env python3

    import csv
    import urllib.request
    import urllib.error
    from urllib.parse import urlparse
    import sys

    def check_url_availability(url):
        \"\"\"Check if a URL is available by sending a HEAD request\"\"\"
        if not url or url.strip() == '':
            return True, "Empty URL - skipping"
        
        try:
            # Create a request with headers to mimic a browser
            req = urllib.request.Request(url, method='HEAD')
            req.add_header('User-Agent', 'Mozilla/5.0 (compatible; URL-Checker/1.0)')
            
            with urllib.request.urlopen(req, timeout=10) as response:
                status_code = response.getcode()
                if status_code == 200:
                    return True, f"Available (HTTP {status_code})"
                else:
                    return False, f"HTTP {status_code}"
        except urllib.error.HTTPError as e:
            return False, f"HTTP Error {e.code}: {e.reason}"
        except urllib.error.URLError as e:
            return False, f"URL Error: {e.reason}"
        except Exception as e:
            return False, f"Error: {str(e)}"

    # Create a mock samplesheet for testing based on input structure
    test_data = '''patient_id,sample_id,tumor_wes_1,tumor_wes_2,tumor_rnaseq_1,tumor_rnaseq_2,normal_wes_1,normal_wes_2
262622,germline,,,,,https://pdmdb.cancer.gov/pdm/262622~v2.0.1.10.0~germlineWES.R1.FASTQ.gz,https://pdmdb.cancer.gov/pdm/262622~v2.0.1.10.0~germlineWES.R2.FASTQ.gz
262622,ORIGINATOR,https://pdmdb.cancer.gov/pdm/262622~085-R~ORIGINATOR~v2.0.2.51.0~WES.R1.FASTQ.gz,https://pdmdb.cancer.gov/pdm/262622~085-R~ORIGINATOR~v2.0.2.51.0~WES.R2.FASTQ.gz,https://pdmdb.cancer.gov/pdm/262622~085-R~ORIGINATOR~v2.0.2.21.0~RNASEQ.R1.FASTQ.gz,https://pdmdb.cancer.gov/pdm/262622~085-R~ORIGINATOR~v2.0.2.21.0~RNASEQ.R2.FASTQ.gz,,
262622,E3E,https://pdmdb.cancer.gov/pdm/262622~085-R~E3E~v2.0.2.51.0~WES.R1.FASTQ.gz,https://pdmdb.cancer.gov/pdm/262622~085-R~E3E~v2.0.2.51.0~WES.R2.FASTQ.gz,https://pdmdb.cancer.gov/pdm/262622~085-R~E3E~v2.0.2.21.0~RNASEQ.R1.FASTQ.gz,https://pdmdb.cancer.gov/pdm/262622~085-R~E3E~v2.0.2.21.0~RNASEQ.R2.FASTQ.gz,,'''

    # Write the test data to the output file
    with open('data_download_samplesheet.csv', 'w') as f:
        f.write(test_data)

    print("\\n=== STUB MODE: URL Availability Check ===\\n")
    
    # Read the samplesheet and check URLs
    with open('data_download_samplesheet.csv', 'r') as infile:
        reader = csv.DictReader(infile)
        
        all_available = True
        total_urls = 0
        available_urls = 0
        
        for row_num, row in enumerate(reader, 1):
            print(f"Row {row_num}: Patient {row['patient_id']}, Sample {row['sample_id']}")
            
            # Check all URL columns
            url_columns = ['tumor_wes_1', 'tumor_wes_2', 'tumor_rnaseq_1', 'tumor_rnaseq_2', 'normal_wes_1', 'normal_wes_2']
            
            for col in url_columns:
                url = row[col].strip()
                if url:  # Only check non-empty URLs
                    total_urls += 1
                    is_available, message = check_url_availability(url)
                    status = "✓" if is_available else "✗"
                    print(f"  {col}: {status} {message}")
                    
                    if is_available:
                        available_urls += 1
                    else:
                        all_available = False
            print()

    print(f"\\n=== Summary ===")
    print(f"Total URLs checked: {total_urls}")
    print(f"Available URLs: {available_urls}")
    print(f"Unavailable URLs: {total_urls - available_urls}")
    print(f"Success rate: {(available_urls/total_urls*100):.1f}%" if total_urls > 0 else "No URLs to check")
    
    if not all_available:
        print("\\n⚠️  WARNING: Some URLs are not available!")
        print("This may indicate:")
        print("- Network connectivity issues")
        print("- Authentication required")
        print("- Files not yet uploaded to the server")
        print("- Incorrect URL formatting")
    else:
        print("\\n✅ All URLs are available!")

    print("\\n📄 Samplesheet created successfully: data_download_samplesheet.csv")
    """
}