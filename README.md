# Samplesheet generator for tylergross97/neoantigen_prediction_workflow

This pipeline is designed to streamline samplesheet creation for the various pipelines used in the neoantigen prediction workflow

The only inputs required are a samplesheet with some basic information (see example below), the path to input base directory (used for building file paths), and the path to the output directory where the generated samplesheets will be stored

```bash
patient_id,sample_id,specimen_id,wes_version,rnaseq_version,germline_version,sex,hla
262622,germline,085-R,2.0.2.51.0,2.0.2.21.0,2.0.1.10.0,female,A*24:02;A*30:04;B*44:03;B*57:01;C*06:02;C*07:06
262622,ORIGINATOR,085-R,2.0.2.51.0,2.0.2.21.0,2.0.1.10.0,female,A*24:02;A*30:04;B*44:03;B*57:01;C*06:02;C*07:06
262622,E3E,085-R,2.0.2.51.0,2.0.2.21.0,2.0.1.10.0,female,A*24:02;A*30:04;B*44:03;B*57:01;C*06:02;C*07:06
262622,E3EN35P99V29,085-R,2.0.2.51.0,2.0.2.21.0,2.0.1.10.0,female,A*24:02;A*30:04;B*44:03;B*57:01;C*06:02;C*07:06
262622,E3EN35P99V29T15,085-R,2.0.2.51.0,2.0.2.21.0,2.0.1.10.0,female,A*24:02;A*30:04;B*44:03;B*57:01;C*06:02;C*07:06
```

