# macsGESTALT lineage tracing analysis workflow
<img width="1548" alt="fig1" src="/github-figs/fig1.png">

**macsGESTALT is an inducible lineage recorder, enabling simultaneous capture of lineages and transcriptomes from single cells** 
**(A)** Genetic components of macsGESTALT. **(B)** Clone-level information is stored in static barcodes, while subclonal phylogenetic information is dynamically encoded into evolving barcodes via insertions and deletions (indels, blue and red bars) induced by administration of doxycycline. **(C)** Two example clones from a population with n clones, each with a random number of integrated barcodes. Evolving barcode edits are encoded and inherited as cells divide. **(D)** Generation of a macsGESTALT barcoded population of cells and experimental workflow. **(E)** macsGESTALT analysis workflow. First, clonal lineage is reconstructed, followed by subclonal reconstruction, and phylogeny building between subclones.



## Paper and data access
* We introduce macsGESTALT and apply it to study cancer metastasis [in our preprint](https://doi.org/10.1101/2020.08.11.245787)
* Raw fastq data from this study can be downloaded from GEO: GSE173958
* All intermediate and processed data files can be downloaded from our [Mendeley Data repository](http://dx.doi.org/10.17632/t98pjcd7t6.1)
* For recreating our study or for testing with example data, we recommended downloading the Mendeley Data repository
* There, all scripts and output and input data files are available and can be run within a coherent directory structure
* Lineage trees from the above paper can be explored interactively with our [tree browser](https://macsgestalt.mckennalab.org/)



## Analysis overview
This readme covers how macsGESTALT single cell lineage tracing data is processed and analyzed from start to finish. It also contains links throughout to where you can find our raw, intermediate, and processed data from the pancreatic cancer metastasis paper.
There are 5 main steps to analysis:
1) [Barcode alignment & indel calling](#step-1-alignment--indel-calling)
2) [Barcode processing & identifying clones based on static barcodes](#step-2-barcode-processing--identifying-clones-based-on-static-barcodes)
3) [Identifying subclones based on evolving barcodes](#step-3-identifying-subclones-based-on-evolving-barcodes)
4) [Intraclonal phylogeny building](#step-4-intraclonal-phylogeny-building)
5) [Build master edgelist & visualization](#step-5-build-master-edgelist--visualization)



## Step 1: Alignment & indel calling
This step collapses barcode sequencing reads by UMI, aligns to a reference barcode sequence, and calls indels at each target site.

### Inputs
* Input files for this step are barcode sequencing demultiplexed fastq files
* The barcode fastq files from our study are available through GEO: GSE173958

### Scripts
* This step is performed with docker and described in more detail [here](https://github.com/mckennalab/SingleCellLineage/)
* The specific docker container for macsGESTALT can be downloaded with: `docker pull aaronmck/single_cell_gestalt:macsGESTALT`
* You will need to transfer the following files (provided) as well as a tearsheet (sample info) file (not provided) to the docker container:  
  * macsGESTALT barcode files: `ref_v82.fa`, `ref_v82.fa.cutSites`, `ref_v82.fa.primers`
  * Run script: `run_crispr_pipeline_v82.sh`
* You can then run the alignment and indel calling pipeline in docker as outlined in the link above

### Outputs
* This pipeline produces a series of files for each sample, but we only use the `.stats` files for downstream processing
* The `.stats` files produced by our study are available through GEO: GSE173958 or through [Mendeley Data](http://dx.doi.org/10.17632/t98pjcd7t6.1)



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
* Corresponding outputs from our study are available through [Mendeley Data](http://dx.doi.org/10.17632/t98pjcd7t6.1)



## Step 3: Identifying subclones based on evolving barcodes
This step consists of another R Notebook, which describes processing in detail inline with code. Briefly, as each cell can contain multiple barcode integrants, these distinct barcodes (defined by their distinct 10bp static identifiers) are merged into a 'barcode-of-barcodes', while also accounting for any missing barcodes that were not recovered in that cell. Cells with identical 'barcode-of-barcodes' are referred to as a 'subclone' as they are indistinguishably closely related. "Barcode-of-barcodes" files are constructed for each clone seperately (as each clone is defined by a different set of static identifiers), which are used downstream for phylogeny building. Note that as our data used pancreatic cancer cells, which are chromosomally unstable, some barcode integrants were duplicated, which impairs downstream reconstruction. Hence, we can't perform subclonal reconstruction on some clones. These are filtered out temporarily at this step and do not have corresponding "barcode-of-barcodes" files.

### Inputs
* `final_editing_data.txt`

### Scripts
* R Notebook: `make-alleles-files.Rmd`

### Outputs
* A "barcode-of-barcodes" file for each clone is created and named as, `clone_XX_for_tree.txt`, and stored in a new directory named `/TreeUtils/clone_hmids`
* Corresponding outputs from our study are available through [Mendeley Data](http://dx.doi.org/10.17632/t98pjcd7t6.1)



## Step 4: Intraclonal phylogeny building
This step uses evolving barcode data from the "barcode-of-barcodes" subclone files to build a seperate tree for each clone, using [TreeUtils]( https://github.com/mckennalab/TreeUtils), which itself uses Camin-Sokal maximum parsimony as implemented in PHYLIP Mix. All of the data files and code used in this section can be downloaded from the `TreeUtils` folder from [Mendeley Data](http://dx.doi.org/10.17632/t98pjcd7t6.1).

### Inputs
* The `TreeUtils/clone_hmids` directory containing `clone_XX_for_tree.txt` files 

### Scripts
* `TreeUtils-assembly-1.3.jar` performs phylogeny building (don't call this directly)
* `build_trees.sh` runs TreeUtils for every clone in the `/TreeUtils/clone_hmids` directory automatically

### Outputs
* All outputs are stored in the `/TreeUtils/clone_trees` directory
* Outputs include json: `clone_XX.json` and newick: `clone_XX.json.newick` files for each processed clone
* Corresponding outputs from our study are available through [Mendeley Data](http://dx.doi.org/10.17632/t98pjcd7t6.1)



## Step 5: Build master edgelist & visualization
This step consists of another R Notebook `make-edgelist.Rmd`, which takes all individual newick clone trees produced in the previous step and collates them into one master tree. This step also adds back cells from clones that did not have a corresponding phylogeny (e.g. due to chromosomal instability and barcode integrant duplication). These trees are merged and stored as an "edgelist". Edgelists can be easily converted to other useful data structures in R, such as a graph using the R package [igraph](https://igraph.org/). This can then be readily visualized as a circle packing plot or tree-based plots using [ggraph](https://ggraph.data-imaginist.com/index.html).

### Inputs
* The `/TreeUtils/clone_trees` directory containing `clone_XX_for_tree.txt` files
* `final_classifications.txt` for clones which do not have corresponding phylogenies
* Additionally, trees can be annotated with single-cell transcriptional information, example scRNA-seq cell metadata (from a Monocle 3 cds) from our metastasis datasets is available through [Mendeley Data](http://dx.doi.org/10.17632/t98pjcd7t6.1), files named `cds_colData.txt`

### Scripts
* R Notebook: `make-edgelist.Rmd` performs all collation steps and includes a visualization vignette

### Outputs
* `full_edgelist.txt`
* Example visualization can be viewed in: `make-edgelist.nb.html`
* Corresponding outputs from our study are available through [Mendeley Data](http://dx.doi.org/10.17632/t98pjcd7t6.1)

















