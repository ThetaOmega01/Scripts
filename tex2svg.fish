#!/usr/bin/env fish

# Usage: ./tex2svg.fish path/to/file.tex

# Ensure exactly one argument
if test (count $argv) -ne 1
    echo "Usage: $argv[0] path/to/file.tex"
    exit 1
end

set texfile $argv[1]

set base (basename $texfile .tex)
set outdir $base-svgs

mkdir -p $outdir

set tmpdir (mktemp -d)

echo "Compiling $texfile to PDF ..."
latexmk -pdf --output-directory=$tmpdir $texfile

set pdffile $tmpdir/$base.pdf
if not test -f $pdffile
    echo "Error: PDF not found at $pdffile"
    exit 2
end

echo "Converting PDF to SVGs with pdf2svg..."
# This will generate files like output-01.svg, output-02.svg, ...
pdf2svg $pdffile $outdir/$base-%02d.svg all

# Clean up temporary directory
rm -rf $tmpdir

echo "Done! SVG files are in: $outdir"
