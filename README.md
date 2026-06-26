# -primer-blast-workflow-
## Overview
Reproducible BLASTn workflow for mapping PCR primer sequences to the BL54591 genome of Drosophila melanogaster. The workflow creates a local BLAST database that filter primer matches, identifies the best hits and selects the best genomic match for each primer.

The BL54591 genome is not available in the NCBI BLAST database making it difficult to evaluate these primers. The goal is to verify whether the PCR primers used in the laboratory are specific enough for the BL54591 genome by identifying their binding sites and target matches.

## Required Files
The following is required to run the workflow:

`genome.fasta` - Reference genome

`primers.fasta` - Primer sequences

Important: Both files must be in FASTA (.fasta) format.

## How to run the Workflow
1. Place both FASTA files in the `data/` directory.

2. Make the script executable:
```bash
chmod +x scripts/run_primer_blast.sh
```
3. Run the workflow
```bash
./scripts/run_primer_blast.sh
```
4. Output files will be generated in the `results/` directory.
