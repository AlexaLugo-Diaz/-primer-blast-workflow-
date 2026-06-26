#!/bin/bash

set -euo pipefail

# Reproducible Primer BLAST workflow

module load GCC/13.3.0 OpenMPI/5.0.3
module load BLAST+/2.16.0

GENOME="data/BL54591.scaffolded.fasta"
PRIMERS="data/primers.fasta"
DB="blast_db/genome_db"
OUTDIR="results"

mkdir -p "$OUTDIR" blast_db

echo "Checking input files..."

if [ ! -f "$GENOME" ]; then
    echo "ERROR: Genome file not found: $GENOME"
    exit 1
fi

if [ ! -f "$PRIMERS" ]; then
    echo "ERROR: Primers file not found: $PRIMERS"
    exit 1
fi

echo "BLAST version:"
blastn -version

echo "Creating BLAST database..."
makeblastdb -in "$GENOME" -dbtype nucl -out "$DB"

echo "Running blastn-short..."
blastn \
  -query "$PRIMERS" \
  -db "$DB" \
  -task blastn-short \
  -dust no \
  -soft_masking false \
  -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen" \
  -out "$OUTDIR/primer_hits.tsv"

echo "Adding column headers..."
echo -e "qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tqlen" > "$OUTDIR/header.tsv"

cat "$OUTDIR/header.tsv" "$OUTDIR/primer_hits.tsv" > "$OUTDIR/primer_hits_with_header.tsv"

echo "Filtering strong primer hits..."
awk '$3 >= 90 && $4 == $13' "$OUTDIR/primer_hits.tsv" > "$OUTDIR/strong_primer_hits.tsv"
cat "$OUTDIR/header.tsv" "$OUTDIR/strong_primer_hits.tsv" > "$OUTDIR/strong_primer_hits_with_header.tsv"

echo "Filtering perfect primer hits..."
awk '$3 == 100 && $4 == $13' "$OUTDIR/primer_hits.tsv" > "$OUTDIR/perfect_primer_hits.tsv"
cat "$OUTDIR/header.tsv" "$OUTDIR/perfect_primer_hits.tsv" > "$OUTDIR/perfect_primer_hits_with_header.tsv"

echo "Selecting best hit per primer..."
sort -k1,1 -k3,3nr -k4,4nr -k11,11g -k12,12nr "$OUTDIR/primer_hits.tsv" | awk '!seen[$1]++' > "$OUTDIR/best_hit_per_primer.tsv"
cat "$OUTDIR/header.tsv" "$OUTDIR/best_hit_per_primer.tsv" > "$OUTDIR/best_hit_per_primer_with_header.tsv"

echo "Workflow complete."
echo "Results are in: $OUTDIR"

echo "Summary:"
echo "Total BLAST hits:"
wc -l "$OUTDIR/primer_hits.tsv"

echo "Strong primer hits:"
wc -l "$OUTDIR/strong_primer_hits.tsv"

echo "Perfect primer hits:"
wc -l "$OUTDIR/perfect_primer_hits.tsv"

echo "Best hit per primer:"
wc -l "$OUTDIR/best_hit_per_primer.tsv"
