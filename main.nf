#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def validateParams() {
    def errors = []
    if (!params.input_base) {
        errors << "ERROR: Please provide --input_base parameter"
    }
    if (!params.samplesheet) {
        errors << "ERROR: Please provide --samplesheet parameter"
    }
    if (!params.outdir_base) {
        errors << "ERROR: Please provide --outdir_base parameter"
    }
    
    // Actually throw an error if there are validation issues
    if (errors.size() > 0) {
        error errors.join('\n')
    }
}

include { RNA_SEQ } from './modules/rna_seq.nf'
include { SAREK } from './modules/sarek.nf'
include { HLATYPING } from './modules/hlatyping.nf'
include { EPITOPE } from './modules/epitope.nf'
include { PURECN } from './modules/purecn.nf'
include { VCF_EXPRESSION_ANNOTATOR } from './modules/vcf_expression_annotator.nf'
include { NEO_DOWNSTREAM } from './modules/neo_downstream.nf'
include { FINAL_MERGE } from './modules/final_merge.nf'
include { XENGSORT } from './modules/xengsort.nf'
include { DB_MERGE } from './modules/db_merge.nf'

workflow {
    validateParams()

    // Create channels
    input_csv = Channel.fromPath(params.samplesheet)
    input_base = Channel.value(params.input_base)
    
    // Conditional execution based on the rna parameter
    if (params.rna) {
        // Run only XENGSORT and RNA_SEQ when --rna is specified
        XENGSORT(input_csv, input_base)
        RNA_SEQ(input_csv, input_base)
    } else {
        // Run all processes when --rna is not specified (default behavior)
        XENGSORT(input_csv, input_base)
        RNA_SEQ(input_csv, input_base)
        SAREK(input_csv, input_base)
        HLATYPING(input_csv, input_base)
        EPITOPE(input_csv, input_base)
        PURECN(input_csv, input_base)
        VCF_EXPRESSION_ANNOTATOR(input_csv, input_base)
        NEO_DOWNSTREAM(input_csv, input_base)
        FINAL_MERGE(input_csv, input_base)
        DB_MERGE(input_csv, input_base)
    }
}