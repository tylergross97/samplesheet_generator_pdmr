#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def validateParams() {
    def errors = []
    if (!params.input_base_dir) {
        errors << "ERROR: Please provide --input_base_dir parameter"
    }
    if (!params.input_csv) {
        errors << "ERROR: Please provide --input_csv parameter"
    }
    if (!params.output_base_dir) {
        errors << "ERROR: Please provide --output_base_dir parameter"
    }
}

include { RNA_SEQ } from './modules/rna_seq.nf'
include { SAREK } from './modules/sarek.nf'

workflow {
    validateParams()

    // Create channels
    input_csv = Channel.fromPath(params.input_csv)
    input_base = Channel.value(params.input_base)
    
    // Run the processes
    RNA_SEQ(input_csv, input_base)
    SAREK(input_csv, input_base )

}