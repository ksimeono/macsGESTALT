# macsGESTALT analysis workflow
Scripts for processing single-cell lineage tracing data using macsGESTALT, as introduced here: https://doi.org/10.1101/2020.08.11.245787


## Overview
There are 5 main steps:
1) Barcode alignment & indel calling
2) Barcode processing & identifying clones based on static barcodes
3) Identifying subclones based on evolving barcodes
4) Intraclonal phylogeny building
5) Build master edgelist & visualization



## Step 1: Alignment & indel calling
This step collapses barcode sequencing reads by UMI, aligns to a reference barcode sequence, and calls indels at each target site.

### Inputs
* Input files for this step are barcode sequencing demultiplexed fastq files
* The barcode fastq files from our study are available through GEO: GSE173958

### Scripts
* This step is performed with docker and described in more detail here: https://github.com/mckennalab/SingleCellLineage/
* The specific docker container for macsGESTALT can be downloaded with: `docker pull aaronmck/single_cell_gestalt:macsGESTALT`
* You will need to transfer the following files (provided) as well as a tearsheet (sample info) file (not provided) to the docker container:  
  * macsGESTALT barcode files: `ref_v82.fa`, `ref_v82.fa.cutSites`, `ref_v82.fa.primers`
  * Run script: `run_crispr_pipeline_v82.sh`
* You can then run the alignment and indel calling pipeline in docker as outlined in the link above

### Outputs
* This pipeline produces a series of files for each sample, but we only use the `.stats` files for downstream processing
* The `.stats` files produced by our study are available through GEO: GSE173958 or through Mendeley Data: XXX



## Step 2: Barcode processing & identifying clones based on static barcodes
This step consists of an R Notebook that provides a more detailed walkthrough of each granular processing step inline with code chunks. It consists of 2 main sections each consisting of a series of smaller steps:
1) Filter aligned barcode sequence data to find real cells and static barcodes
2) Discover clones and classify cells into clones via static barcode content

### Inputs
* `.stats` files for each sample produced in the step above
* A list of real singlets with which to perform initial filtering
  * Either from transcriptional analysis, for our data this is: `whitelist_cancer_cells.txt`
  * If you're using your own data and you don't have matched transcriptional data, you can simply use 10x's v3 cellranger 3' mRNA whitelist instead

### Scripts
* R Notebook: `clonal-processing.Rmd`

### Outputs
* The `clonal-processing.nb.html` file for each mouse contains summary plots and running summary tables for different steps of the workflow
* `precluster_filtered.txt` is a large file containing all aligned data remaining after the organizational and QC steps of the "Section 1" portion
* `final_singlets.txt` is a large file containing all info from alignment pipeline for final remaining singlets after all steps
    - this includes all aligned transcripts as individual rows and full barcode sequences
* `final_classifications.txt` concisely stores cell type (i.e. singlet, doublet, unmatched, etc) and cloneID if a cell is matched and a singlet
* `final_editing_data.txt` is used for phylogeny building scripts downstream
* Only `final_classifications.txt` and `final_editing_data.txt` will be used downstream
* These outputs from our study are available through Mendeley Data: XXX



## Step 3: Identifying subclones based on evolving barcodes
This step consists of another R Notebook which describes processing in detail inline with code. Briefly, as each cell can contain multiple barcode integrants, these distinct barcodes (defined by their distinct 10bp static identifiers) are merged into a 'barcode-of-barcodes', while also accounting for any missing barcodes that were not recovered in that cell. Cells with identical 'barcode-of-barcodes' are referred to as a 'subclone' as they are indistinguishably closely related. "Barcode-of-barcodes" files are constructed for each clone seperately (as each clone is defined by a different set of static identifiers), which are used downstream for phylogeny building. Note that as our data used pancreatic cancer cells, which are chromosomally unstable, some barcode integrants were duplicated, which impairs downstream reconstruction. Hence, we can't perform subclonal reconstruction on some clones. These are filtered out temporarily at this step and do not have corresponding "barcode-of-barcodes" files.

### Inputs
* `final_editing_data.txt`

### Scripts
* R Notebook: `make-alleles-files.Rmd`

### Outputs
* A "barcode-of-barcodes" file for each clone is created and named as, `clone_XX_for_tree.txt`, and stored in a new directory named `clone_hmids`
* These outputs from our study are available through Mendeley Data: XXX



## Step 4: Intraclonal phylogeny building
This step uses evolving barcode data from the "barcode-of-barcodes" subclone files to build a seperate tree for each clone, using TreeUtils: https://github.com/mckennalab/TreeUtils, which itself uses Camin-Sokal maximum parsimony as implemented in PHYLIP Mix. All of the data files and code used in this section can be downloaded from the `TreeUtils` folder in Mendeley Data: XXX

### Inputs
* The `clone_hmids` directory containing `clone_XX_for_tree.txt` files 

### Scripts
* 

### Outputs
* A "barcode-of-barcodes" file for each clone is created and named as, `clone_XX_for_tree.txt`, and stored in a new directory named `clone_hmids`
* These outputs from our study are available through Mendeley Data: XXX








