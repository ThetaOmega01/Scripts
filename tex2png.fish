#!/usr/bin/env fish

# Ensure exactly one argument
if test (count $argv) -ne 1
    echo "Usage: $argv[0] path/to/file.tex"
    exit 1
end

# Input .tex file
set texfile $argv[1]

# Derive base name and output directory
set base (basename $texfile .tex)
set outdir $base-pngs

# Create output directory
mkdir -p $outdir

# Create temporary output directory for TeX
set tmpdir (mktemp -d)

echo "Compiling $texfile to PDF ..."
latexmk -pdf -output-directory=$tmpdir $texfile

# Locate the generated PDF
set pdffile $tmpdir/$base.pdf
if not test -f $pdffile
    echo "Error: PDF not found at $pdffile"
    exit 2
end

echo "Converting PDF to PNGs with pdftoppm (600 DPI)..."
magick -density 300 $pdffile $outdir/$base.png

# Clean up temporary directory
rm -rf $tmpdir

echo "Done! PNG files are in: $outdir"
