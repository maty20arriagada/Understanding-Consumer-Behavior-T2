# ==============================================================================
# Run All Script - Homework Assignment No. 2
# This script automates running the R analysis and compiling the PDF outputs.
# ==============================================================================

import subprocess
import os
import sys

def run_command(command, description):
    print(f"\n>>> Running: {description}...")
    print(f"Command: {command}")
    try:
        # Run using shell=True to support Powershell/CMD commands on Windows
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        print("Stdout:")
        print(result.stdout)
        if result.stderr:
            print("Stderr:")
            print(result.stderr)
        print(f"SUCCESS: {description}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"ERROR: {description} failed.")
        print(f"Exit code: {e.returncode}")
        print("Stdout:")
        print(e.stdout)
        print("Stderr:")
        print(e.stderr)
        return False

def main():
    print("======================================================================")
    print("HW02 - Understanding Consumer Behavior - Automation Pipeline")
    print("======================================================================")

    # 1. Run R Analysis
    r_command = '"C:\\Program Files\\R\\R-4.5.3\\bin\\Rscript.exe" analysis.R'
    if not run_command(r_command, "R Econometric Analysis and Plotting"):
        print("Pipeline aborted due to R script failure.")
        sys.exit(1)

    # 2. Compile Report to PDF
    report_command = 'pandoc report.md -o HW02_Written_Report.pdf --pdf-engine=pdflatex -V geometry:margin=1in -V fontsize=11pt'
    if not run_command(report_command, "Compiling written report (report.md -> HW02_Written_Report.pdf)"):
        print("Pipeline aborted due to report compilation failure.")
        sys.exit(1)

    # 3. Compile Presentation to PDF
    presentation_command = 'pandoc presentation.md -o HW02_Oral_Presentation.pdf -t beamer --pdf-engine=pdflatex'
    if not run_command(presentation_command, "Compiling presentation slides (presentation.md -> HW02_Oral_Presentation.pdf)"):
        print("Pipeline aborted due to presentation compilation failure.")
        sys.exit(1)

    print("\n======================================================================")
    print("PIPELINE COMPLETED SUCCESSFULLY!")
    print("Generated files:")
    print("1. HW02_Written_Report.pdf  - Complete academic report")
    print("2. HW02_Oral_Presentation.pdf - Slides for the presentation")
    print("3. output_plots/            - High-resolution figures used in the report")
    print("4. output_tables/           - Raw tables and CSV summaries")
    print("======================================================================")

if __name__ == "__main__":
    main()
