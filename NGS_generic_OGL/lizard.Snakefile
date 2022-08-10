from os.path import join
import sys
import datetime

def chr_GVCF_to_single_GVCF(wildcards):
	# creates the filenames for the chr level GVCFs to use to concatenate to a single file
	# ensures that input GVCF chrs are provided in order (same as CHRS) below
	sample = str(wildcards)
	sample_by_chr = []
	for chrom in CHRS:
		sample_by_chr.append('gvcfs/chr_split/' + sample + '/' + sample + '__' + str(chrom) + '.g.vcf.gz')
	return(sample_by_chr)

def chr_fbVCF_to_single_fbVCF_filtered(wildcards):
	# creates the filenames for the chr level GVCFs to use to concatenate to a single file
	# ensures that input GVCF chrs are provided in order (same as CHRS) below
	sample = str(wildcards)
	sample_by_chr = []
	for chrom in CHRS:
		sample_by_chr.append('freebayes/chr_split/' + sample + '/' + sample + '__' + str(chrom) + '.filtered.vcf.gz')
	return(sample_by_chr)

def chr_fbVCF_to_single_fbVCF_phased(wildcards):
	# creates the filenames for the chr level GVCFs to use to concatenate to a single file
	# ensures that input GVCF chrs are provided in order (same as CHRS) below
	sample = str(wildcards)
	sample_by_chr = []
	for chrom in CHRS:
		sample_by_chr.append('freebayes/chr_split/' + sample + '/' + sample + '__' + str(chrom) + '.phased.vcf.gz')
	return(sample_by_chr)

def chr_fbVCF_to_single_fbVCF(wildcards):
	# creates the filenames for the chr level GVCFs to use to concatenate to a single file
	# ensures that input GVCF chrs are provided in order (same as CHRS) below
	sample = str(wildcards)
	sample_by_chr = []
	for chrom in CHRS:
		sample_by_chr.append('freebayes/chr_split/' + sample + '/' + sample + '__' + str(chrom) + '.vcf.gz')
	return(sample_by_chr)

def chr_bam_to_single_bam(wildcards):
	# creates the filenames for the chr level bams to use to concatenate to a single file
	sample = str(wildcards)
	sample_by_chr = []
	for chrom in CHRS:
		sample_by_chr.append('sample_bam/chr_split/' + sample + '/' + sample + '__' + str(chrom) + '.CleanSam.sorted.markDup.bam')
	return(sample_by_chr)

def chr_scramble_to_single_scramble(wildcards):
	# creates the filenames for the chr level GVCFs to use to concatenate to a single file
	# ensures that input GVCF chrs are provided in order (same as CHRS) below
	sample = str(wildcards)
	sample_by_chr = []
	for chrom in CHRS:
		sample_by_chr.append('scramble/chr_split/' + sample + '/' + sample + '__' + str(chrom) + '.scramble.tsv')
	return(sample_by_chr)

# the 'metadata_file' is a csv with three columns
# the first is the sample name (e.g. Patient001)
# the second is the name of the fastq or bam associated with the sample
# the third is the read group you want bwa to use
# 	example: '@RG\\tID:Lineagen_41001412010527\\tSM:Lineagen_41001412010527\\tPL:ILLUMINA'
# a header isn't required, but if it is included it MUST start with #:
# 	#Sample,File
# you can have multiple lines per sample
# most samples are paired end, so there will be at least two files per sample
# often you have a sample sequenced across multiple lanes/machines, so you can have
# upwards of a dozen files for a single sample
SAMPLE_LANEFILE = dict()
LANEFILE_READGROUP = dict()
metadata = open(config['metadata_file'])
for line in metadata:
	read_group = line.split(',')[2][:-1]
	lane_file = line.split(',')[1]
	sample = line.split(',')[0]
	# skip header
	if line.startswith("#"):
		continue
	if sample not in SAMPLE_LANEFILE:
		SAMPLE_LANEFILE[sample] = [lane_file]
	else:
		old_lane_file = SAMPLE_LANEFILE[sample]
		old_lane_file.append(lane_file)
		SAMPLE_LANEFILE[sample] = old_lane_file
	LANEFILE_READGROUP[lane_file] = [read_group]
metadata.close()

# for i in SAMPLE_LANEFILE:
# 	print (i, SAMPLE_LANEFILE[i], len(SAMPLE_LANEFILE[i]))
# for i in LANEFILE_READGROUP:
# 	print (i, LANEFILE_READGROUP[i], len(LANEFILE_READGROUP[i]))

if config['analysis_batch_name'] == 'YYYYMMDD':
	currentDT = datetime.datetime.now()
	config['analysis_batch_name'] = currentDT.strftime("%Y%m%d")

if config['inputFileType'].upper() in ['BAM', 'CRAM']:
	def rg(wildcards):
		# returns the read group given in the config['metadata_file']
		lane_file = str(wildcards)
		rg_out = str(LANEFILE_READGROUP[str(SAMPLE_LANEFILE[lane_file][0])]).replace("['", "").replace("']","")
		return(rg_out)
else:
	def rg(wildcards):
		# returns the read group given in the config['metadata_file']
		lane_file = str(wildcards)
		rg_out = str(LANEFILE_READGROUP[lane_file + config['lane_pair_delim'][0] + '.gz'][0])
		return(rg_out)

if config['genomeBuild'].upper() in ['GRCH37', 'hg19']:
	config['ref_genome'] = '/data/OGL/resources/1000G_phase2_GRCh37/human_g1k_v37_decoy.fasta'
	config['bwa-mem2_ref'] = '/data/OGL/resources/1000G_phase2_GRCh37/bwa-mem2/human_g1k_v37_decoy.fasta'
	config['SCRAMBLEdb'] = '/data/OGL/resources/SCRAMBLEvariantClassification.xlsx'
	CHRS=["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y","MT_contigs"]
	MT_CONTIGS = "MT GL000207.1 GL000226.1 GL000229.1 GL000231.1 GL000210.1 GL000239.1 GL000235.1 GL000201.1 GL000247.1 GL000245.1 GL000197.1 GL000203.1 GL000246.1 GL000249.1 GL000196.1 GL000248.1 GL000244.1 GL000238.1 GL000202.1 GL000234.1 GL000232.1 GL000206.1 GL000240.1 GL000236.1 GL000241.1 GL000243.1 GL000242.1 GL000230.1 GL000237.1 GL000233.1 GL000204.1 GL000198.1 GL000208.1 GL000191.1 GL000227.1 GL000228.1 GL000214.1 GL000221.1 GL000209.1 GL000218.1 GL000220.1 GL000213.1 GL000211.1 GL000199.1 GL000217.1 GL000216.1 GL000215.1 GL000205.1 GL000219.1 GL000224.1 GL000223.1 GL000195.1 GL000212.1 GL000222.1 GL000200.1 GL000193.1 GL000194.1 GL000225.1 GL000192.1 NC_007605"
elif config['genomeBuild'].upper() in ['GRCH38', 'hg38']:
	CHRS=["chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY","MT_contigs"]
	MT_CONTIGS = "chrM chr1_KI270706v1_random chr1_KI270707v1_random chr1_KI270708v1_random chr1_KI270709v1_random chr1_KI270710v1_random chr1_KI270711v1_random chr1_KI270712v1_random chr1_KI270713v1_random chr1_KI270714v1_random chr2_KI270715v1_random chr2_KI270716v1_random chr3_GL000221v1_random chr4_GL000008v2_random chr5_GL000208v1_random chr9_KI270717v1_random chr9_KI270718v1_random chr9_KI270719v1_random chr9_KI270720v1_random chr11_KI270721v1_random chr14_GL000009v2_random chr14_GL000225v1_random chr14_KI270722v1_random chr14_GL000194v1_random chr14_KI270723v1_random chr14_KI270724v1_random chr14_KI270725v1_random chr14_KI270726v1_random chr15_KI270727v1_random chr16_KI270728v1_random chr17_GL000205v2_random chr17_KI270729v1_random chr17_KI270730v1_random chr22_KI270731v1_random chr22_KI270732v1_random chr22_KI270733v1_random chr22_KI270734v1_random chr22_KI270735v1_random chr22_KI270736v1_random chr22_KI270737v1_random chr22_KI270738v1_random chr22_KI270739v1_random chrY_KI270740v1_random chrUn_KI270302v1 chrUn_KI270304v1 chrUn_KI270303v1 chrUn_KI270305v1 chrUn_KI270322v1 chrUn_KI270320v1 chrUn_KI270310v1 chrUn_KI270316v1 chrUn_KI270315v1 chrUn_KI270312v1 chrUn_KI270311v1 chrUn_KI270317v1 chrUn_KI270412v1 chrUn_KI270411v1 chrUn_KI270414v1 chrUn_KI270419v1 chrUn_KI270418v1 chrUn_KI270420v1 chrUn_KI270424v1 chrUn_KI270417v1 chrUn_KI270422v1 chrUn_KI270423v1 chrUn_KI270425v1 chrUn_KI270429v1 chrUn_KI270442v1 chrUn_KI270466v1 chrUn_KI270465v1 chrUn_KI270467v1 chrUn_KI270435v1 chrUn_KI270438v1 chrUn_KI270468v1 chrUn_KI270510v1 chrUn_KI270509v1 chrUn_KI270518v1 chrUn_KI270508v1 chrUn_KI270516v1 chrUn_KI270512v1 chrUn_KI270519v1 chrUn_KI270522v1 chrUn_KI270511v1 chrUn_KI270515v1 chrUn_KI270507v1 chrUn_KI270517v1 chrUn_KI270529v1 chrUn_KI270528v1 chrUn_KI270530v1 chrUn_KI270539v1 chrUn_KI270538v1 chrUn_KI270544v1 chrUn_KI270548v1 chrUn_KI270583v1 chrUn_KI270587v1 chrUn_KI270580v1 chrUn_KI270581v1 chrUn_KI270579v1 chrUn_KI270589v1 chrUn_KI270590v1 chrUn_KI270584v1 chrUn_KI270582v1 chrUn_KI270588v1 chrUn_KI270593v1 chrUn_KI270591v1 chrUn_KI270330v1 chrUn_KI270329v1 chrUn_KI270334v1 chrUn_KI270333v1 chrUn_KI270335v1 chrUn_KI270338v1 chrUn_KI270340v1 chrUn_KI270336v1 chrUn_KI270337v1 chrUn_KI270363v1 chrUn_KI270364v1 chrUn_KI270362v1 chrUn_KI270366v1 chrUn_KI270378v1 chrUn_KI270379v1 chrUn_KI270389v1 chrUn_KI270390v1 chrUn_KI270387v1 chrUn_KI270395v1 chrUn_KI270396v1 chrUn_KI270388v1 chrUn_KI270394v1 chrUn_KI270386v1 chrUn_KI270391v1 chrUn_KI270383v1 chrUn_KI270393v1 chrUn_KI270384v1 chrUn_KI270392v1 chrUn_KI270381v1 chrUn_KI270385v1 chrUn_KI270382v1 chrUn_KI270376v1 chrUn_KI270374v1 chrUn_KI270372v1 chrUn_KI270373v1 chrUn_KI270375v1 chrUn_KI270371v1 chrUn_KI270448v1 chrUn_KI270521v1 chrUn_GL000195v1 chrUn_GL000219v1 chrUn_GL000220v1 chrUn_GL000224v1 chrUn_KI270741v1 chrUn_GL000226v1 chrUn_GL000213v1 chrUn_KI270743v1 chrUn_KI270744v1 chrUn_KI270745v1 chrUn_KI270746v1 chrUn_KI270747v1 chrUn_KI270748v1 chrUn_KI270749v1 chrUn_KI270750v1 chrUn_KI270751v1 chrUn_KI270752v1 chrUn_KI270753v1 chrUn_KI270754v1 chrUn_KI270755v1 chrUn_KI270756v1 chrUn_KI270757v1 chrUn_GL000214v1 chrUn_KI270742v1 chrUn_GL000216v2 chrUn_GL000218v1 chrEBV"
else:
	print("ref_genome is ", config['ref_genome'])
	print("bwa-mem2_ref is", config['bwa-mem2_ref'])
	CHRS=["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y","MT_contigs"]
	MT_CONTIGS = "MT GL000207.1 GL000226.1 GL000229.1 GL000231.1 GL000210.1 GL000239.1 GL000235.1 GL000201.1 GL000247.1 GL000245.1 GL000197.1 GL000203.1 GL000246.1 GL000249.1 GL000196.1 GL000248.1 GL000244.1 GL000238.1 GL000202.1 GL000234.1 GL000232.1 GL000206.1 GL000240.1 GL000236.1 GL000241.1 GL000243.1 GL000242.1 GL000230.1 GL000237.1 GL000233.1 GL000204.1 GL000198.1 GL000208.1 GL000191.1 GL000227.1 GL000228.1 GL000214.1 GL000221.1 GL000209.1 GL000218.1 GL000220.1 GL000213.1 GL000211.1 GL000199.1 GL000217.1 GL000216.1 GL000215.1 GL000205.1 GL000219.1 GL000224.1 GL000223.1 GL000195.1 GL000212.1 GL000222.1 GL000200.1 GL000193.1 GL000194.1 GL000225.1 GL000192.1 NC_007605"

wildcard_constraints:
	sample='|'.join(list(SAMPLE_LANEFILE.keys())),
	chr = '|'.join(CHRS),
	lane = '|'.join(list(set([re.split(r'|'.join(config['lane_pair_delim']),x.split('/')[-1])[0] for x in [y for sub in list(SAMPLE_LANEFILE.values()) for y in sub]])))

rule all:
	input:
		#expand('gvcfs/{sample}.g.vcf.gz', sample=list(SAMPLE_LANEFILE.keys())) if config['GATKgvcf'] == 'TRUE' else 'dummy.txt',
		expand('bam/{sample}.cram', sample=list(SAMPLE_LANEFILE.keys())) if config['cram'] == 'TRUE' else expand('bam/{sample}.bam', sample=list(SAMPLE_LANEFILE.keys())),
		# 'GATK_metrics/multiqc_report' if config['multiqc'] == 'TRUE' else 'dummy.txt',
		'fastqc/multiqc_report' if config['multiqc'] == 'TRUE' else 'dummy.txt',
		 expand('picardQC/{sample}.insert_size_metrics.txt', sample=list(SAMPLE_LANEFILE.keys())) if config['picardQC'] == 'TRUE' else 'dummy.txt',
		#'deepvariant/deepvariantVcf.merge.done.txt' if config['deepvariant'] == 'TRUE' else 'dummy.txt',
		#'prioritization/dv_fb.merge.done.txt' if config['freebayes_phasing'] == 'TRUE' else 'dummy.txt',
		'coverage/mean.coverage.done.txt' if config['coverage'] == 'TRUE' else 'dummy.txt',
		#'mutserve/haplocheck.done.txt',
		#expand('manta/manta.{sample}.annotated.tsv', sample=list(SAMPLE_LANEFILE.keys())) if config['manta'] == 'TRUE' else 'dummy.txt',
		#expand('scramble_anno/{sample}.scramble.tsv', sample=list(SAMPLE_LANEFILE.keys())) if config['SCRAMble'] == 'TRUE' else 'dummy.txt',
		#expand('AutoMap/{sample}/{sample}.HomRegions.annot.tsv', sample=list(SAMPLE_LANEFILE.keys())),
		#'bcmlocus/combine.bcmlocus.done.txt'

localrules: dummy
rule dummy:
	input:
		config['metadata_file']
	output:
		temp('dummy.txt')
	shell:
		"""
		touch {output}
		"""

#9/1/2021: cram of USUPH data under the settings did not work with 56 threads because of sambamba cannot write when using 200G lscratch, also it took a long time to queue if using 56 threads and 20h walltime
#9/1/2021: Threads 28, 400g lscratch, 100g mem, 12h walltime, is quick to run. Took 9h13min - 12h40min, upto 53gb memory
#may reduce to 36 threads: https://blog.dnanexus.com/2020-03-10-bwa-mem2-review/
#tested bwa-mem2, sambamba or with biobambam2. Sambamba shown here is 1.5-2x faster.
#When using 139 panel data for test, samblaster marked 3.3% dup, biobambam2 3.4%, sambamba 6.7%. biobambam2 is similar to picard.
#fastqc then would re-calculate the markdup because it showed samblaster markduped 139 to be 7.8%, and picard-markdupped 2226 to 12.5% from 5.7%
if config['inputFileType'] == 'single_lane_fastq':
	rule align_markdup:
		input:
			expand('fastq/{{lane}}{pair}.gz', pair = config['lane_pair_delim'])
		output:
			bam = temp('lane_bam/{lane}.bam'),
			bai = temp('lane_bam/{lane}.bam.bai')
		params:
			read_group = rg
		threads: 56
		shell:
			"""
			export TMPDIR=/lscratch/$SLURM_JOB_ID
			echo {params.read_group}
			module load {config[bwa-mem2_version]} {config[samblaster_version]} {config[sambamba_version]}
			case "{config[markDup]}" in
				"TRUE")
					bwa-mem2 mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -R {params.read_group} \
						{config[bwa-mem2_ref]} {input} \
			 			| samblaster -M --addMateTags --quiet \
						| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o {output.bam} \
						<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
					;;
				"FALSE")
					bwa-mem2 mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -R {params.read_group} \
						{config[bwa-mem2_ref]} {input} \
			 			| samblaster -M --acceptDupMarks --addMateTags --quiet \
						| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o {output.bam} \
						<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
					;;
			esac
			#sambamba index -t {threads} {output.bam} {output.bai}
			"""
	localrules: cp_lane_bam
	rule cp_lane_bam:
		input:
			bam = lambda wildcards: expand('lane_bam/{lane}.bam', lane = list(set([re.split(r'|'.join(config['lane_pair_delim']),x.split('/')[-1])[0] for x in SAMPLE_LANEFILE[wildcards.sample]]))),
			bai = lambda wildcards: expand('lane_bam/{lane}.bam.bai', lane = list(set([re.split(r'|'.join(config['lane_pair_delim']),x.split('/')[-1])[0] for x in SAMPLE_LANEFILE[wildcards.sample]])))
		output:
			bam = temp('sample_bam/{sample}.markDup.bam'),
			bai = temp('sample_bam/{sample}.markDup.bai')
		shell:
			"""
			cp -p -l {input.bam} {output.bam}
			cp -p -l {input.bai} {output.bai}
			"""
elif config['inputFileType'].upper() in ['BAM', 'CRAM']:
	rule realign: # up to 12.5h for cram
		input:
			lambda wildcards: join('old_bam/', str(SAMPLE_LANEFILE[wildcards.sample][0]))
		output:
			bam = temp('sample_bam/{sample}.markDup.bam'),
			bai = temp('sample_bam/{sample}.markDup.bai')
		threads: 36
		params:
			read_group = rg
		shell:
			"""
			export TMPDIR=/lscratch/$SLURM_JOB_ID
			module load {config[bazam_version]}
			module load {config[bwa_version]} {config[samblaster_version]} {config[sambamba_version]}
			BAMFILE={input}
			if [ -e {input}.bai ] || [ -e ${{BAMFILE%.bam}}.bai ] || [ -e {input}.crai ] || [ -e ${{BAMFILE%.cram}}.crai ] ; then
				echo "index present"
			else
				module load {config[samtools_version]}
				samtools index -@ $(({threads}-2)) {input}
			fi
 			case "{input}" in
				*bam)
					if [[ "{config[markDup]}" == "TRUE" ]]; then
						java -Xmx24g -jar $BAZAMPATH/bazam.jar -bam {input} \
						| bwa mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -p -R {params.read_group} {config[ref_genome]} - \
				 		| samblaster -M --addMateTags --quiet \
						| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o {output.bam} \
							<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
						mv {output.bam}.bai {output.bai}
					elif [[ "{config[markDup]}" == "FALSE" ]]; then
						java -Xmx24g -jar $BAZAMPATH/bazam.jar -bam {input} \
						| bwa mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -p -R {params.read_group} {config[ref_genome]} - \
				 		| samblaster -M --acceptDupMarks --addMateTags --quiet \
						| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o {output.bam} \
							<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
						mv {output.bam}.bai {output.bai}
					else
						java -Xmx24g -jar $BAZAMPATH/bazam.jar -bam {input} \
							| bwa-mem2 mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -p -R {params.read_group} {config[bwa-mem2_ref]} \
							| samblaster -M --acceptDupMarks --addMateTags --quiet \
							| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o /lscratch/$SLURM_JOB_ID/{wildcards.sample}.bam \
								<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
						module load {config[biobambam2_version]}
						bammarkduplicatesopt markthreads={threads} level=6 \
							tmpfile=/lscratch/$SLURM_JOB_ID/{wildcards.sample} \
							I=/lscratch/$SLURM_JOB_ID/{wildcards.sample}.bam \
							O={output.bam} \
							M={output.bam}.markDup.metrics.txt \
							index=1 indexfilename={output.bai}
					fi
					#sambamba index -t {threads} {output.bam} {output.bai}
					;;
				*cram)
					if [[ "{config[markDup]}" == "TRUE" ]]; then
						java -Xmx24g -Dsamjdk.reference_fasta={config[old_cram_ref]} -jar $BAZAMPATH/bazam.jar -bam {input} \
							| bwa mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -p -R {params.read_group} {config[ref_genome]} - \
				 			| samblaster -M --addMateTags --quiet \
							| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o {output.bam} \
								<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
						mv {output.bam}.bai {output.bai}
					elif [[ "{config[markDup]}" == "FALSE" ]]; then
						java -Xmx24g -Dsamjdk.reference_fasta={config[old_cram_ref]} -jar $BAZAMPATH/bazam.jar -bam {input} \
							| bwa mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -p -R {params.read_group} {config[ref_genome]} - \
				 			| samblaster -M --acceptDupMarks --addMateTags --quiet \
							| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o {output.bam} \
								<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
						mv {output.bam}.bai {output.bai}
					else
						java -Xmx24g -Dsamjdk.reference_fasta={config[old_cram_ref]} -jar $BAZAMPATH/bazam.jar -bam {input} \
							| bwa-mem2 mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -p -R {params.read_group} {config[bwa-mem2_ref]} - \
				 			| samblaster -M --acceptDupMarks --addMateTags --quiet \
							| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o /lscratch/$SLURM_JOB_ID/{wildcards.sample}.bam \
								<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
						module load {config[biobambam2_version]}
						bammarkduplicatesopt markthreads={threads} level=6 \
							tmpfile=/lscratch/$SLURM_JOB_ID/{wildcards.sample} \
							I=/lscratch/$SLURM_JOB_ID/{wildcards.sample}.bam \
							O={output.bam} \
							M={output.bam}.markDup.metrics.txt \
							index=1 indexfilename={output.bai}
					fi
					;;
			esac
			"""
else:
	rule align:
		input:
			# config['lane_pair_delim'] is the string differentiating
			# the forward from reverse
			# e.g. ['_R1_001', '_R2_001'] if the file names are
			# sample17_R1_001.fastq.gz and sample17_R2_001.fastq.gz
			# for a set of paired end fastq
			# if you don't have a paired fastq set, give as ['']
			# 2 hours 15 min/32g mem/400g_lscratch
			expand('fastq/{{lane}}{pair}.gz', pair = config['lane_pair_delim'])
		output:
			bam = temp('lane_bam/{lane}.bam'),
			bai = temp('lane_bam/{lane}.bam.bai')
		params:
			read_group = rg
		threads: 56
		shell:
			"""
			export TMPDIR=/lscratch/$SLURM_JOB_ID
			echo {params.read_group}
			module load {config[bwa-mem2_version]} {config[samblaster_version]} {config[sambamba_version]}
			case "{config[markDup]}" in
				"TRUE")
					bwa-mem2 mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -R {params.read_group} \
						{config[bwa-mem2_ref]} {input} \
			 			| samblaster -M --addMateTags --quiet \
						| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o {output.bam} \
						<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
					;;
				*)
					bwa-mem2 mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -R {params.read_group} \
						{config[bwa-mem2_ref]} {input} \
			 			| samblaster -M --acceptDupMarks --addMateTags --quiet \
						| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o {output.bam} \
						<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
					;;
			esac
			"""
	rule merge_lane_bam:
		input:
			bam = lambda wildcards: expand('lane_bam/{lane}.bam', lane = list(set([re.split(r'|'.join(config['lane_pair_delim']),x.split('/')[-1])[0] for x in SAMPLE_LANEFILE[wildcards.sample]]))),
			bai = lambda wildcards: expand('lane_bam/{lane}.bam.bai', lane = list(set([re.split(r'|'.join(config['lane_pair_delim']),x.split('/')[-1])[0] for x in SAMPLE_LANEFILE[wildcards.sample]])))
		output:
			bam = temp('sample_bam/{sample}.markDup.bam'),
			bai = temp('sample_bam/{sample}.markDup.bai')
		threads: 32
		shell:
			"""
			module load {config[sambamba_version]}
			case "{input.bam}" in
				*\ *)
					sambamba merge -t {threads} -l 6 {output.bam} {input.bam}
					mv {output.bam}.bai {output.bai}
					;;
				*)
					cp {input.bam} {output.bam}
					cp {input.bai} {output.bai}
					;;
			esac
			"""
#bammarkduplicates metrix to stderr if not set -M=file.txt
#https://manpages.debian.org/unstable/biobambam2/bammarkduplicatesopt.1.en.html
#sambamba markdup -t {threads} -l 6 --tmpdir /lscratch/$SLURM_JOB_ID \
#	/lscratch/$SLURM_JOB_ID/{output.bam} {output.bam}
#picard, sambamba, or samblaster marked 40% reads as dup for PCR-free libraries (USUPH etc), thus create snakemake file that does not have markdup.
#sambamba markdup is much faster than picard, finished in 50 min 6g mem with 16 threads.
#samblaster --addMateTags for SV calling later? samblaster also MarkDuplicates
#The following bwa-mem2 and biobambam2 worked, but one WGS sample did not get processed well (28 threads < 25g mememory used, <9 hours);
# if using 56 or more threads, it likely will be faster.
			# module load {config[bwa-mem2_version]}
			# module load {config[biobambam2_version]}
			# bwa-mem2 mem -t {threads} -K 100000000 -M -B 4 -O 6 -E 1 -R {params.read_group} \
			# 	{config[ref_genome]} {input} \
			# 	| bamsormadup SO=coordinate threads={threads} level=6 inputformat=sam \
			# 	tmpfile=/lscratch/$SLURM_JOB_ID/bamsormadup \
			# 	indexfilename={output.bai} M={output.metrics} > {output.bam}

# export TMPDIR=/lscratch/$SLURM_JOB_ID necessary?

# bwa mem -K 100000000 : process input bases in each batch reardless of nThreads (for reproducibility));
# -Y : use soft clipping for supplementary alignments. This is necessary for CREST.
# -M : mark shorter split hits as secondary. David used -M
# flag -M is compatible with lumpy: https://genomebiology.biomedcentral.com/articles/10.1186/gb-2014-15-6-r84
#-B 4 -O 6 -E 1 : these are bwa mem default.

#Optical duplicates marking only does not work May 2021.
				# *)
				# 	bwa-mem2 mem -t $(({threads}-2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -R {params.read_group} \
				# 		{config[bwa-mem2_ref]} {input} \
			 	# 		| samblaster -M --acceptDupMarks --addMateTags --quiet \
				# 		| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}-2)) -o /lscratch/$SLURM_JOB_ID/{wildcards.lane}.bam \
				# 		<(sambamba view -S -f bam -l 0 -t $(({threads}-2)) /dev/stdin)
				# 	module load {config[biobambam2_version]}
				# 	bammarkduplicatesopt markthreads={threads} level=6 \
				# 		tmpfile=/lscratch/$SLURM_JOB_ID/{wildcards.sample} \
				# 		I=/lscratch/$SLURM_JOB_ID/{wildcards.lane}.bam \
				# 		O={output.bam} \
				# 		M={output.bam}.markDup.metrics.txt \
				# 		index=1 indexfilename={output.bai}
				# 	;;

rule fastqc:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		directory('fastqc/{sample}')
	threads: 8
	shell:
		"""
		module load fastqc
		mkdir -p fastqc
		mkdir -p fastqc/{wildcards.sample}
		fastqc -t {threads} -o {output} {input.bam}
		"""
rule multiqc_fastqc:
	input:
		expand('fastqc/{sample}', sample=list(SAMPLE_LANEFILE.keys()))
	output:
		directory('fastqc/multiqc_report')
	shell:
		"""
		module load multiqc
		multiqc -f -o {output} fastqc/
		"""
#finished <10 min for one sample job.
rule picard_alignmentQC:
#insert size and alignment metrics
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		insert_size_metrics = 'picardQC/{sample}.insert_size_metrics.txt',
		insert_size_histogram = 'picardQC/{sample}.insert_size_histogram.pdf',
		alignment_metrics = 'picardQC/{sample}.alignment_metrics.txt'
	threads: 4
	shell:
		"""
		module load {config[picard_version]} {config[R_version]}
		java -Xmx32g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
			CollectInsertSizeMetrics \
			-TMP_DIR /lscratch/$SLURM_JOB_ID \
			--INPUT {input.bam} \
			-O {output.insert_size_metrics} \
		    -H {output.insert_size_histogram} \
		    -M 0.5
		java -Xmx32g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
			CollectAlignmentSummaryMetrics \
			-TMP_DIR /lscratch/$SLURM_JOB_ID \
			--INPUT {input.bam} \
			-R {config[ref_genome]} \
			--METRIC_ACCUMULATION_LEVEL SAMPLE \
			--METRIC_ACCUMULATION_LEVEL READ_GROUP \
			-O {output.alignment_metrics}
		"""

#localrules: coverage
rule coverage:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		thresholds = 'coverage/mosdepth/{sample}.md.thresholds.bed.gz',
		summary = 'coverage/mosdepth/{sample}.md.mosdepth.summary.txt',
		region_summary = temp('coverage/mosdepth/{sample}.region.summary.tsv'),
		xlsx = 'coverage/{sample}.coverage.xlsx'
	threads: 8
	shell:
		"""
		module load {config[mosdepth_version]}
		module load {config[R_version]}
		cd coverage/mosdepth
		mosdepth -t {threads} --no-per-base --use-median --mapq 0 --fast-mode \
			{wildcards.sample}.md ../../{input.bam}
		cd ../..
		#mv {wildcards.sample}.md.* coverage/mosdepth/.
		#zcat {output.thresholds} \
		#	 | sed '1 s/^.*$/chr\tstart\tend\tgene\tcoverageTen\tcoverageTwenty\tcoverageThirty/' \
		#	 > {output.thresholds}.tsv
		#echo -e "sample\tlength\tmean" > {output.region_summary}
		#tail -n 1 {output.summary} | cut -f 2,4 | sed 's/^/{wildcards.sample}\t/' >> {output.region_summary}
		#Rscript ~/git/NGS_genotype_calling/NGS_generic_OGL/mosdepth_bed_coverage.R \
		#	{output.thresholds}.tsv {config[OGL_Dx_research_genes]} {output.region_summary} {output.xlsx}
		#rm {output.thresholds}.tsv
		"""

localrules: mean_coverage
rule mean_coverage:
	input:
		expand('coverage/mosdepth/{sample}.md.mosdepth.summary.txt', sample=list(SAMPLE_LANEFILE.keys()))
	output:
		'coverage/mean.coverage.done.txt'
	shell:
		"""
		echo -e "sample\tlength\tmean" > coverage/{config[analysis_batch_name]}.mean.region.coverage.summary.tsv
		echo -e "sample\tlength\tmean" > coverage/{config[analysis_batch_name]}.mean.genome.coverage.summary.tsv
		for file in {input}; do
			filename=$(basename $file)
			sm=$(echo $filename | sed 's/.md.mosdepth.summary.txt//')
			tail -n 1 $file | cut -f 2,4 | sed 's/^/'"$sm"'\t/' >> coverage/{config[analysis_batch_name]}.mean.region.coverage.summary.tsv
			tail -n 2 $file | head -n 1 | cut -f 2,4 | sed 's/^/'"$sm"'\t/' >> coverage/{config[analysis_batch_name]}.mean.genome.coverage.summary.tsv
 		done
		touch {output}
		"""

# 30% smaller!
rule bam_to_cram:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		cram = 'bam/{sample}.cram',
		crai = 'bam/{sample}.crai'
	threads:
		8
	shell:
		"""
		module load {config[samtools_version]}
		samtools view -T {config[ref_genome]} --threads {threads} --output-fmt cram,store_md=1,store_nm=1 -o {output.cram} {input.bam}
		samtools index -@ {threads} {output.cram} {output.crai}
		"""
# samtools view -T {config[ref_genome]} --threads {threads} -C -o {output.cram} {input.bam}
# samtools view -O cram,store_md=1,store_nm=1 -o aln.cram aln.bam
# samtools view --input-fmt cram,decode_md=0 -o aln.new.bam aln.cram

localrules: keep_bam
rule keep_bam:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		bam = 'bam/{sample}.bam',
		bai = 'bam/{sample}.bai'
	shell:
		"""
		cp -p -l {input.bam} {output.bam}
		cp -p -l {input.bai} {output.bai}
		"""

#1h40min 22g max mem
rule deepvariantS1:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		examples = temp(directory('deepvariant/{sample}/examples')),
		gvcf_tfrecords = temp(directory('deepvariant/{sample}/gvcf_tfrecords'))
	threads: 56
	shell:
		"""
		module load {config[deepvariant_version]} parallel
		mkdir -p deepvariant/{wildcards.sample}/examples deepvariant/{wildcards.sample}/gvcf_tfrecords
		BASE=$PWD
		PROJECT="${{BASE}}/deepvariant/{wildcards.sample}"
		N_SHARDS=$SLURM_CPUS_PER_TASK
		WORK_DIR="/lscratch/${{SLURM_JOB_ID}}"
		DV_OUTPUT_DIR="${{WORK_DIR}}/output"
		DV_INPUT_DIR="${{WORK_DIR}}/input"
		TMPDIR="${{WORK_DIR}}/temp"
		LOG="${{WORK_DIR}}/logs"
		EXAMPLES="${{DV_OUTPUT_DIR}}/{wildcards.sample}.examples.tfrecord@${{N_SHARDS}}.gz"
		GVCF_TFRECORDS="${{DV_OUTPUT_DIR}}/{wildcards.sample}.gvcf.tfrecord@${{N_SHARDS}}.gz"
		rm -rf $WORK_DIR/input $WORK_DIR/output $WORK_DIR/logs $WORK_DIR/temp
		mkdir -p $WORK_DIR/input $WORK_DIR/output $WORK_DIR/logs $WORK_DIR/temp
		cp {input} {config[ref_genome]} {config[ref_genome]}.fai $DV_INPUT_DIR || exit 1
		( time seq 0 $((N_SHARDS-1)) | parallel -j {threads} --eta --halt 2 --line-buffer \
			make_examples --mode calling \
			--ref  $DV_INPUT_DIR/$(basename {config[ref_genome]}) \
			--reads $DV_INPUT_DIR/$(basename {input.bam}) \
			--examples "${{EXAMPLES}}" \
			--gvcf "${{GVCF_TFRECORDS}}" \
			--task {{}} \
		) 2>&1 | tee "${{LOG}}/{wildcards.sample}.make_examples.log"
		echo "Done." || exit 1
		cp ${{DV_OUTPUT_DIR}}/{wildcards.sample}.examples.* ${{PROJECT}}/examples
		cp ${{DV_OUTPUT_DIR}}/{wildcards.sample}.gvcf.* ${{PROJECT}}/gvcf_tfrecords || exit 1
		"""

#45min; changed threads from 24 to 14 on 12/17/20, since p100 & v100 gpu has 56 cpus and 4 gpus per node. CPUs only used briefly during runs
# "extra" : "--constraint='[gpuv100|gpup100|gpuv100x]' --gres=lscratch:100,gpu:1",
rule deepvariantS2:
	input:
		'deepvariant/{sample}/examples'
	output:
		temp('deepvariant/{sample}/call_variants/{sample}.call_variants_output.tfrecord.gz')
	threads: 8
	shell:
		"""
		module load {config[deepvariant_version]}
		BASE=$PWD
		PROJECT="${{BASE}}/deepvariant/{wildcards.sample}"
		N_SHARDS="56"
		WORK_DIR="/lscratch/${{SLURM_JOB_ID}}"
		DV_OUTPUT_DIR="${{WORK_DIR}}/output"
		DV_INPUT_DIR="${{WORK_DIR}}/input"
		TMPDIR="${{WORK_DIR}}/temp"
		LOG="${{WORK_DIR}}/logs"
		EXAMPLES="${{DV_OUTPUT_DIR}}/{wildcards.sample}.examples.tfrecord@${{N_SHARDS}}.gz"
		GVCF_TFRECORDS="${{DV_OUTPUT_DIR}}/{wildcards.sample}.gvcf.tfrecord@${{N_SHARDS}}.gz"
		CALL_VARIANTS_OUTPUT="${{DV_OUTPUT_DIR}}/{wildcards.sample}.call_variants_output.tfrecord.gz"
		rm -rf $WORK_DIR/input $WORK_DIR/output $WORK_DIR/logs $WORK_DIR/temp
		mkdir -p $WORK_DIR/input $WORK_DIR/output $WORK_DIR/logs $WORK_DIR/temp
		cp ${{PROJECT}}/examples/* ${{DV_OUTPUT_DIR}} || exit 1
		MODEL="/opt/models/wgs/model.ckpt"
		( time \
    		call_variants \
    		--outfile "${{CALL_VARIANTS_OUTPUT}}" \
    		--examples "${{EXAMPLES}}" \
    		--checkpoint "${{MODEL}}" \
		) 2>&1 | tee "${{LOG}}/{wildcards.sample}.call_variants.log"
		echo "Done." || exit 2
		cp ${{CALL_VARIANTS_OUTPUT}} ${{PROJECT}}/call_variants || exit 3
		"""

#90min
rule deepvariantS3:
	input:
		examples = 'deepvariant/{sample}/examples',
		gvcf_tfrecords = 'deepvariant/{sample}/gvcf_tfrecords',
		tfrecord = 'deepvariant/{sample}/call_variants/{sample}.call_variants_output.tfrecord.gz',
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		vcf = 'deepvariant/vcf/{sample}.vcf.gz',
		gvcf = 'deepvariant/gvcf/{sample}.g.vcf.gz'
	threads: 4
	shell:
		"""
		module load {config[deepvariant_version]} parallel
		BASE=$PWD
		PROJECT="${{BASE}}/deepvariant/{wildcards.sample}"
		N_SHARDS="56"
		WORK_DIR="/lscratch/${{SLURM_JOB_ID}}"
		DV_OUTPUT_DIR="${{WORK_DIR}}/output"
		DV_INPUT_DIR="${{WORK_DIR}}/input"
		TMPDIR="${{WORK_DIR}}/temp"
		LOG="${{WORK_DIR}}/logs"
		EXAMPLES="${{DV_OUTPUT_DIR}}/{wildcards.sample}.examples.tfrecord@${{N_SHARDS}}.gz"
		GVCF_TFRECORDS="${{DV_OUTPUT_DIR}}/{wildcards.sample}.gvcf.tfrecord@${{N_SHARDS}}.gz"
		CALL_VARIANTS_OUTPUT="${{DV_OUTPUT_DIR}}/{wildcards.sample}.call_variants_output.tfrecord.gz"
		CV_FILE="{wildcards.sample}.call_variants_output.tfrecord.gz"
		OUTPUT_VCF="${{DV_OUTPUT_DIR}}/{wildcards.sample}.vcf.gz"
		OUTPUT_GVCF="${{DV_OUTPUT_DIR}}/{wildcards.sample}.g.vcf.gz"
		rm -rf $WORK_DIR/input $WORK_DIR/output $WORK_DIR/logs $WORK_DIR/temp
		mkdir -p $WORK_DIR/input $WORK_DIR/output $WORK_DIR/logs $WORK_DIR/temp
		cp ${{PROJECT}}/gvcf_tfrecords/* {config[ref_genome]} {config[ref_genome]}.fai ${{PROJECT}}/call_variants/${{CV_FILE}} ${{DV_OUTPUT_DIR}} || exit 1
		( time \
    		postprocess_variants \
      		--ref $DV_OUTPUT_DIR/$(basename {config[ref_genome]}) \
      		--infile "${{CALL_VARIANTS_OUTPUT}}" \
      		--outfile "${{OUTPUT_VCF}}" \
      		--nonvariant_site_tfrecord_path "${{GVCF_TFRECORDS}}" \
      		--gvcf_outfile "${{OUTPUT_GVCF}}" \
		) 2>&1 | tee "${{LOG}}/{wildcards.sample}.postprocess_variants.log" || exit 1
		cp ${{OUTPUT_VCF}}* ${{DV_OUTPUT_DIR}}/*.html deepvariant/vcf || exit 2
		cp ${{OUTPUT_GVCF}}* deepvariant/gvcf || exit 2
		"""

rule glnexus:
	input:
		vcf = expand('deepvariant/gvcf/{sample}.g.vcf.gz', sample=list(SAMPLE_LANEFILE.keys())),
		#bam = expand('sample_bam/{sample}.markDup.bam', sample=list(SAMPLE_LANEFILE.keys())),
		#bai = expand('sample_bam/{sample}.markDup.bai', sample=list(SAMPLE_LANEFILE.keys()))
	output:
		'deepvariant/deepvariant.gvcf.merge.done.txt'
	threads: 72
	shell:
		"""
		module load {config[glnexus_version]} {config[samtools_version]}
		WORK_DIR="/lscratch/${{SLURM_JOB_ID}}"
		glnexus --dir /lscratch/$SLURM_JOB_ID/glnexus --config DeepVariant \
			--threads $(({threads} - 8)) --mem-gbytes 512 \
			{input.vcf} \
			| bcftools norm --multiallelics -any --output-type u --no-version \
			| bcftools norm --check-ref s --fasta-ref {config[ref_genome]} --output-type u --no-version - \
			| bcftools +fill-tags - -Ou -- -t AC,AC_Hom,AC_Het,AN,AF \
			| bcftools annotate --threads $(({threads} - 8)) --set-id 'dv_%CHROM\:%POS%REF\>%ALT' --no-version - -Oz -o deepvariant/{config[analysis_batch_name]}.glnexus.vcf.gz
		tabix -f -p vcf deepvariant/{config[analysis_batch_name]}.glnexus.vcf.gz
		touch {output}
		"""

#took 55min & 43G mem.
rule dv_whatshap:
	input:
		glnexus = 'deepvariant/deepvariant.gvcf.merge.done.txt',
		#vcf = 'deepvariant/vcf/{sample}.vcf.gz',
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		phasedvcf = 'deepvariant/vcf/{sample}.dv.phased.vcf.gz',
		phasedtbi = 'deepvariant/vcf/{sample}.dv.phased.vcf.gz.tbi'
	threads: 26
	shell:
		"""
		module load {config[samtools_version]} {config[whatshap_version]} parallel
		WORK_DIR="/lscratch/${{SLURM_JOB_ID}}"
		FILTEREDVCF="/lscratch/$SLURM_JOB_ID/{wildcards.sample}.vcf.gz"
		rm -rf $WORK_DIR/*
		cp deepvariant/{config[analysis_batch_name]}.glnexus.vcf.gz* /lscratch/$SLURM_JOB_ID
		bcftools view --threads {threads} -Oz --samples {wildcards.sample} $WORK_DIR/{config[analysis_batch_name]}.glnexus.vcf.gz \
			-o $WORK_DIR/{wildcards.sample}.vcf.gz && rm $WORK_DIR/{config[analysis_batch_name]}.glnexus.vcf.gz*
		tabix -f -p vcf $WORK_DIR/{wildcards.sample}.vcf.gz
		CONTIGFILE="/data/OGL/resources/whatshap/vcf.contig.filename.{config[genomeBuild]}.txt"
		cp {config[ref_genome]} {config[ref_genome]}.fai {input.bam} {input.bai} $WORK_DIR
		mkdir -p /lscratch/$SLURM_JOB_ID/filtered
		mkdir -p /lscratch/$SLURM_JOB_ID/phased
		( cat $CONTIGFILE | parallel -C "\t" -j 21 "bcftools filter --threads $(({threads}-6)) -r {{1}} --output-type z $FILTEREDVCF -o $WORK_DIR/filtered/{{2}}.filtered.vcf.gz" ) && echo "Filtered vcf split to chr" || exit 5
		( cat $CONTIGFILE | parallel -C "\t" -j 21 "tabix -f -p vcf $WORK_DIR/filtered/{{2}}.filtered.vcf.gz" ) && echo "Chr vcf index created" || exit 6
		( cat $CONTIGFILE | parallel -C "\t" -j 21 --tmpdir $WORK_DIR --eta --halt 2 --line-buffer \
		 	--tag "whatshap phase --reference $WORK_DIR/$(basename {config[ref_genome]}) \
			--indels --ignore-read-groups $WORK_DIR/filtered/{{2}}.filtered.vcf.gz $WORK_DIR/{wildcards.sample}.markDup.bam \
			| bgzip -f --threads $(({threads}-10)) > $WORK_DIR/phased/{{2}}.phased.vcf.gz" \
		) && echo "whatshap on chr completed" || exit 7
		( cat $CONTIGFILE | parallel -C "\t" -j 21 "tabix -f -p vcf $WORK_DIR/phased/{{2}}.phased.vcf.gz" ) && echo "Phased-chr vcf index created" || exit 8
		PHASEDCHRFILE=""
		cut -f 2 $CONTIGFILE > $WORK_DIR/temp.chr.txt
		while read line; do PHASEDCHRFILE+=" /lscratch/${{SLURM_JOB_ID}}/phased/$line.phased.vcf.gz"; done < $WORK_DIR/temp.chr.txt
		echo "chr files are $PHASEDCHRFILE"
		bcftools concat --threads {threads} --output-type z $PHASEDCHRFILE > {output.phasedvcf} || exit 8
		tabix -f -p vcf {output.phasedvcf}
		"""
#deepvariant separates MNPs, thus no need to use decompose_blocksub.
#deepvariant normalizes most indels, but not all, thus bcftools norm needed
#deepvariant does not inlucde duplicate variant, thus no need to use -d none, but codes included anyway.
#samtools 1.11: bcftools filter --include 'FILTER="PASS"'
rule merge_deepvariantVcf:
	input:
		vcf = expand('deepvariant/vcf/{sample}.dv.phased.vcf.gz', sample=list(SAMPLE_LANEFILE.keys())),
		tbi = expand('deepvariant/vcf/{sample}.dv.phased.vcf.gz.tbi', sample=list(SAMPLE_LANEFILE.keys()))
	output:
		'deepvariant/deepvariantVcf.merge.done.txt'
	threads: 16
	shell:
		"""
		module load {config[samtools_version]}
		case "{input.vcf}" in
			*\ *)
				bcftools merge --merge none --missing-to-ref --output-type z --threads {threads} {input.vcf} \
				> deepvariant/{config[analysis_batch_name]}.dv.phased.vcf.gz
				sleep 2
				tabix -f -p vcf deepvariant/{config[analysis_batch_name]}.dv.phased.vcf.gz
				;;
			*)
				cp -p -l {input.vcf} deepvariant/{config[analysis_batch_name]}.dv.phased.vcf.gz
				cp -p -l {input.tbi} deepvariant/{config[analysis_batch_name]}.dv.phased.vcf.gz.tbi
				;;
		esac
		touch {output}
		"""


#2hours for MEI only, used 1.4g mememory.
#including deletion takes > 12h for some and ~32g mem, thus need parallel or split runs.
rule scramble:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		cluster = temp('scramble/{sample}.cluster.txt'),
		mei = 'scramble/{sample}_MEIs.txt'
	shell:
		"""
		module load {config[scramble_version]}
		scramble cluster_identifier {input.bam} > {output.cluster}
		scramble Rscript --vanilla /app/cluster_analysis/bin/SCRAMble.R \
			--out-name ${{PWD}}/scramble/{wildcards.sample} \
			--cluster-file ${{PWD}}/{output.cluster} \
			--install-dir /app/cluster_analysis/bin \
			--mei-refs /app/cluster_analysis/resources/MEI_consensus_seqs.fa \
			--ref {config[ref_genome]} \
			--eval-meis \
			--no-vcf
		"""
#		dels =  'scramble/{sample}_PredictedDeletions.txt'
#			--eval-dels \ removed because deletion calling take s long time and other tools already check deletion.
#--bind /gpfs,/spin1,/data,/lscratch,/scratch,/fdb
#finished in seconds, <100Mb memory
localrules: scramble_annotation
rule scramble_annotation:
	input:
		mei = 'scramble/{sample}_MEIs.txt'
	output:
		avinput = temp('scramble_anno/{sample}.avinput'),
		annovarR = temp('scramble_anno/{sample}.forR.txt'),
		anno = 'scramble_anno/{sample}.scramble.tsv',
		anno_xlsx = 'scramble_anno/{sample}.scramble.xlsx'
	shell:
		"""
		if [[ $(module list 2>&1 | grep "annovar" | wc -l) < 1 ]]; then module load {config[annovar_version]}; fi
		if [[ $(module list 2>&1 | grep "R/" | wc -l) < 1 ]]; then module load {config[R_version]}; fi
		if [[ {config[genomeBuild]} == "GRCh38" ]]; then
			ver=hg38
		else
			ver=hg19
		fi
		if [[ $(wc -l {input.mei} | cut -d " " -f 1) == 1 ]]
		then
			touch {output.avinput}
			touch {output.annovarR}
			touch {output.anno}
			touch {output.anno_xlsx}
		else
			cut -f 1 {input.mei} | awk -F ":" 'BEGIN{{OFS="\t"}} NR>1 {{print $1,$2,$2,"0","-"}}' > {output.avinput}
			table_annovar.pl {output.avinput} \
				$ANNOVAR_DATA/$ver \
				-buildver $ver \
				-remove \
				-out scramble_anno/{wildcards.sample} \
				--protocol refGene \
				-operation g \
				--argument '-splicing 100 -hgvs' \
				--polish -nastring . \
				--thread 1
			awk -F"\t" 'BEGIN{{OFS="\t"}} NR==1 {{print "Func_refGene","Gene","Intronic","AA"}} NR>1 {{print $6,$7,$8,$10}}' scramble_anno/{wildcards.sample}."$ver"_multianno.txt | paste {input.mei} - > {output.annovarR}
			rm scramble_anno/{wildcards.sample}."$ver"_multianno.txt
			Rscript /home/$USER/git/NGS_genotype_calling/NGS_generic_OGL/scramble_anno.R {output.annovarR} {config[SCRAMBLEdb]} {config[OGL_Dx_research_genes]} {config[HGMDtranscript]} {wildcards.sample} {output.anno} {output.anno_xlsx}
		fi
		"""

#<30min, 3gb max mem
rule manta:
	input:
 		bam = 'sample_bam/{sample}.markDup.bam',
 		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		'manta/manta.{sample}.annotated.tsv'
	threads: 56
	shell:
		"""
		module load {config[manta_version]}
		mkdir -p /lscratch/$SLURM_JOB_ID/manta/{wildcards.sample}
		RUNDIR="/lscratch/$SLURM_JOB_ID/manta/{wildcards.sample}"
		configManta.py --referenceFasta {config[ref_genome]} \
			--runDir $RUNDIR --bam {input.bam}
		$RUNDIR/runWorkflow.py -m local -j {threads} -g $((SLURM_MEM_PER_NODE / 1024))
		cp $RUNDIR/results/variants/diploidSV.vcf.gz manta/{wildcards.sample}.diploidSV.vcf.gz
		cp $RUNDIR/results/variants/diploidSV.vcf.gz.tbi manta/{wildcards.sample}.diploidSV.vcf.gz.tbi
		module load {config[annotsv_version]}
		AnnotSV -SVinputFile $RUNDIR/results/variants/diploidSV.vcf.gz \
			-SVinputInfo 1 -genomeBuild {config[genomeBuild]} \
			-outputDir $RUNDIR \
			-outputFile $RUNDIR/manta.{wildcards.sample}.annotated.tsv
		cp $RUNDIR/manta.{wildcards.sample}.annotated.tsv {output}
		"""
#manta takes ~30min if working fine, 32 threads and 3G mem.
#SV, use 16 threads and 64 g
# rule sve:
# 	input:
# 		bam = 'sample_bam/{sample}.bam',
# 		bai = 'sample_bam/{sample}.bai'
# 	output:
# 		bai = 'sample_bam/{sample}.bam.bai',
# 		vcf = 'sve/{sample}/{sample}_S4.vcf'
# 	shell:
# 		"""
# 		module load sve/0.1.0 parallel
# 		cp {input.bai} {output.bai}
# 		parallel -j 6 --tmpdir /lscratch/$SLURM_JOB_ID "sve call -r /data/OGL/resources/1000G_phase2_GRCh37/human_g1k_v37_decoy.fasta -o sve/CTNS.217 -t 4 -M 4 -g hg19 -a {} bam/CTNS.217.bam" ::: breakdancer breakseq cnvnator delly lumpy cnmops
# 		for method in breakdancer breakseq cnvnator delly lumpy cnmops; do
# 		 	sve call -r {config[ref_genome]} -o sve/{wildcards.sample} \
# 			-t 16 -M 4 -g hg19 -a $method {input.bam}; done
# 		"""

localrules: mutserve
rule mutserve:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		vcf = 'mutserve/{sample}.mt.vcf.gz',
		tbi = 'mutserve/{sample}.mt.vcf.gz.tbi'
	resources: res=1
	shell:
		"""
		if [[ $(module list 2>&1 | grep "samtools" | wc -l) < 1 ]]; then module load {config[samtools_version]}; fi
		MUTSERVE_HOME="/data/OGL/resources/git/mutserve"
		$MUTSERVE_HOME/mutserve call --reference $MUTSERVE_HOME/rCRS.fasta --output {output.vcf} --threads 2 {input.bam}
		$MUTSERVE_HOME/mutserve annotate --input mutserve/{wildcards.sample}.txt --annotation $MUTSERVE_HOME/rCRS_annotation_2020-08-20.txt --output mutserve/{wildcards.sample}.AnnotatedVariants.txt
		tabix -f -p vcf {output.vcf}
		"""

localrules: haplocheck
rule haplocheck:
	input:
		vcf = expand('mutserve/{sample}.mt.vcf.gz', sample=list(SAMPLE_LANEFILE.keys())),
		tbi = expand('mutserve/{sample}.mt.vcf.gz.tbi', sample=list(SAMPLE_LANEFILE.keys()))
	output:
		'mutserve/haplocheck.done.txt'
	shell:
		"""
		if [[ $(module list 2>&1 | grep "samtools" | wc -l) < 1 ]]; then module load {config[samtools_version]}; fi
		case "{input.vcf}" in
			*\ *)
				bcftools merge --merge none --missing-to-ref --output-type z {input.vcf} \
				> mutserve/{config[analysis_batch_name]}.mt.vcf.gz
				sleep 2
				tabix -f -p vcf mutserve/{config[analysis_batch_name]}.mt.vcf.gz
				;;
			*)
				cp -p -l {input.vcf} mutserve/{config[analysis_batch_name]}.mt.vcf.gz
				cp -p -l {input.tbi} mutserve/{config[analysis_batch_name]}.mt.vcf.gz.tbi
				;;
		esac
		HAPLOCHECK_HOME="/data/OGL/resources/git/haplocheck"
		$HAPLOCHECK_HOME/haplocheck --out mutserve/{config[analysis_batch_name]} mutserve/{config[analysis_batch_name]}.mt.vcf.gz
		touch {output}
		"""

rule bcm_locus:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai',
		#bam = 'bam/{sample}.cram',
		#bai = 'bam/{sample}.crai'
	output:
		bam = 'bam/bcmlocus/{sample}.bcm.bam',
		bai = 'bam/bcmlocus/{sample}.bcm.bai',
		vcf = temp('bcmlocus/{sample}.vcf'),
		avinput = temp('bcmlocus/{sample}.avinput'),
		bcm_out = 'bcmlocus/{sample}.bcmlocus.tsv'
	threads: 8
	shell:
		"""
		export TMPDIR=/lscratch/$SLURM_JOB_ID
		module load {config[samtools_version]} {config[bazam_version]} {config[bwa-mem2_version]} {config[samblaster_version]} {config[sambamba_version]}
		#took 150min? why so long?
		RG=$(samtools view -H {input.bam} | grep "^@RG" | head -n 1 | sed 's/\t/\\\\t/g')
		#java -Xmx16g -Dsamjdk.reference_fasta={config[ref_genome]} -jar $BAZAMPATH/bazam.jar -f "pair.r1.referenceIndex == pair.r2.referenceIndex" -bam {input.bam} --regions chrX:153929000-154373500 \
		#| bwa-mem2 mem -t $(({threads}/2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -p -R $RG {config[GRCh38Decoy2]} - \
		java -Xmx16g -jar $BAZAMPATH/bazam.jar -bam {input.bam} --regions chrX:153929000-154373500 \
		| bwa-mem2 mem -t $(({threads}/2)) -K 100000000 -M -Y -B 4 -O 6 -E 1 -p -R $RG {config[GRCh38Decoy2]} - \
		| samblaster -M --addMateTags --quiet \
		| sambamba sort -u --tmpdir=/lscratch/$SLURM_JOB_ID -t $(({threads}/2)) -o {output.bam} \
			<(sambamba view -S -f bam -l 0 -t $(({threads}/2)) /dev/stdin)
		mv {output.bam}.bai {output.bai}
		if [[ $(module list 2>&1 | grep "mosdepth" | wc -l) < 1 ]]; then module load {config[mosdepth_version]}; fi
		if [[ $(module list 2>&1 | grep "R/" | wc -l) < 1 ]]; then module load {config[R_version]}; fi
		mkdir -p bcmlocus/mosdepth
		cd bcmlocus/mosdepth
		mosdepth -t {threads} --no-per-base --by {config[bcmlocus_bed]} --use-median --mapq 0 --fast-mode \
			{wildcards.sample}.md ../../{output.bam}
		cd ../..
		if [[ $(module list 2>&1 | grep "samtools" | wc -l) < 1 ]]; then module load {config[samtools_version]}; fi
		if [[ $(module list 2>&1 | grep "freebayes" | wc -l) < 1 ]]; then module load {config[freebayes_version]}; fi
		if [[ $(module list 2>&1 | grep "annovar" | wc -l) < 1 ]]; then module load {config[annovar_version]}; fi
		freebayes -f {config[GRCh38Decoy2]}  --max-complex-gap 90 -p 6 -C 3 -F 0.05 \
			--genotype-qualities --strict-vcf --use-mapping-quality \
			--targets /data/OGL/resources/bed/OPN1LWe2e5.bed \
			{output.bam} \
			| bcftools norm --multiallelics -any --output-type u - \
			| bcftools annotate --set-id '%CHROM\:%POS%REF\>%ALT' -x ^INFO/AF --output-type u --no-version \
			| bcftools norm --check-ref s --fasta-ref {config[GRCh38Decoy2]}  --output-type u --no-version - \
			| bcftools norm -d exact --output-type v - \
			> {output.vcf}
		convert2annovar.pl -format vcf4old {output.vcf} -includeinfo --outfile {output.avinput}
		if [[ {config[genomeBuild]} == "GRCh38" ]]; then
			ver=hg38
		else
			ver=hg19
		fi
		if [[ -s {output.avinput} ]]; then
			table_annovar.pl {output.avinput} \
				$ANNOVAR_DATA/$ver \
				-buildver $ver \
				-remove \
				-out {output.avinput} \
				--protocol refGeneWithVer \
				-operation g \
				--argument '-hgvs' \
				--polish -nastring . \
				--thread 1 \
				--otherinfo
			sed -i "1 s/Otherinfo1\tOtherinfo2\tOtherinfo3\tOtherinfo4\tOtherinfo5\tOtherinfo6\tOtherinfo7\tOtherinfo8\tOtherinfo9\tOtherinfo10/CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tGT_FIELDS/" bcmlocus/{wildcards.sample}.avinput."$ver"_multianno.txt
			if [[ $(module list 2>&1 | grep "R/" | wc -l) < 1 ]]; then module load {config[R_version]}; fi
			Rscript ~/git/NGS_genotype_calling/NGS_generic_OGL/bcmlocus.R \
				/data/OGL/resources/bcmlocus.xlsx \
				{wildcards.sample} bcmlocus/{wildcards.sample}.avinput."$ver"_multianno.txt {output.bcm_out}
			rm bcmlocus/{wildcards.sample}.avinput."$ver"_multianno.txt
		else
			touch {output.bcm_out}
		fi
		"""
## Next step: get CN information

localrules: combine_bcmlocus
rule combine_bcmlocus:
	input:
		expand('bcmlocus/{sample}.bcmlocus.tsv', sample=list(SAMPLE_LANEFILE.keys()))
	output:
		'bcmlocus/combine.bcmlocus.done.txt'
	shell:
		"""
		echo -e "CHROM\tPOS\tID\tREF\tALT\tQUAL\tFunc.refGeneWithVer\tGene.refGeneWithVer\tGeneDetail.refGeneWithVer\tExonicFunc.refGeneWithVer\tAAChange.refGeneWithVer\tHGVSp\tAnnotation\tFunction\tACMG_Class\tNote\tSample\tINFO\tFORMAT\tGT_FIELDS" > bcmlocus/{config[analysis_batch_name]}.bcmlocus.all.tsv
		for file in {input}; do
			tail -n 1 $file >> bcmlocus/{config[analysis_batch_name]}.bcmlocus.all.tsv
 		done
		touch {output}
		"""

#<40min, 9g max mem
rule split_bam_by_chr:
	input:
		bam = 'sample_bam/{sample}.markDup.bam',
		bai = 'sample_bam/{sample}.markDup.bai'
	output:
		bam = temp('sample_bam/chr_split/{sample}/{sample}__{chr}.bam'),
		bai = temp('sample_bam/chr_split/{sample}/{sample}__{chr}.bai'),
		#metrics = temp('sample_bam/chr_split/{sample}/{sample}__{chr}.markdup.metrics.txt')
	threads: 4
	shell:
		"""
		module load {config[samtools_version]} {config[sambamba_version]}
		if [[ {wildcards.chr} != "MT_contigs" ]]; then
			samtools view -h --threads {threads} --output-fmt BAM {input.bam} {wildcards.chr} > {output.bam}
			sambamba index -t {threads} {output.bam} {output.bai}
		else
			samtools view -h --threads {threads} --output-fmt BAM {input.bam} {MT_CONTIGS} > {output.bam}
			sambamba index -t {threads} {output.bam} {output.bai}
		fi
		"""
#3/28/21 removed because problem with biobambam2, maybe due to new version. markdup and sort seems not necessary because it's done previously.
# samtools view -h --threads {threads} --output-fmt SAM {input.bam} {wildcards.chr} \
# | bamsormadup SO=coordinate threads={threads} level=6 inputformat=sam \
# tmpfile=/lscratch/$SLURM_JOB_ID/bamsormadup \
# index=1 indexfilename={output.bai} M={output.metrics} > {output.bam}
#70min for longest run chr2, 16G max used.
rule freebayes_phasing:
	input:
		bam = 'sample_bam/chr_split/{sample}/{sample}__{chr}.bam',
		bai = 'sample_bam/chr_split/{sample}/{sample}__{chr}.bai'
	output:
		vcf = temp('freebayes/chr_split/{sample}/{sample}__{chr}.vcf.gz'),
		tbi = temp('freebayes/chr_split/{sample}/{sample}__{chr}.vcf.gz.tbi'),
		filteredvcf = temp('freebayes/chr_split/{sample}/{sample}__{chr}.filtered.vcf.gz'),
		filteredtbi = temp('freebayes/chr_split/{sample}/{sample}__{chr}.filtered.vcf.gz.tbi'),
		phasedvcf = temp('freebayes/chr_split/{sample}/{sample}__{chr}.phased.vcf.gz'),
		phasedvcf_tbi = temp('freebayes/chr_split/{sample}/{sample}__{chr}.phased.vcf.gz.tbi')
	threads: 32
	shell:
		"""
		module load {config[freebayes_version]}
		module load {config[vcflib_version]}
		module load {config[samtools_version]}
		module load {config[vt_version]}
		if [[ {wildcards.chr} != "MT_contigs" ]]; then
			freebayes-parallel /data/OGL/resources/freebayesRegion/{config[genomeBuild]}/region.{wildcards.chr} {threads} -f {config[ref_genome]} \
				--skip-coverage 1000 {input.bam} --min-alternate-fraction 0.05 \
				--min-mapping-quality 1 --genotype-qualities --strict-vcf --use-mapping-quality \
				| bcftools norm --multiallelics -any --output-type v - \
				| vt decompose_blocksub -p -m -d 2 - \
				| bcftools norm --check-ref s --fasta-ref {config[ref_genome]} --output-type u - \
				| bcftools norm -d exact --output-type z - -o {output.vcf}
		else
			freebayes-parallel /data/OGL/resources/freebayesRegion/{config[genomeBuild]}/region.{wildcards.chr} {threads} -f {config[ref_genome]} \
				--limit-coverage 500 {input.bam} --min-alternate-fraction 0.05 \
				--min-mapping-quality 1 --genotype-qualities --strict-vcf --use-mapping-quality \
				| bcftools norm --multiallelics -any --output-type v - \
				| vt decompose_blocksub -p -m -d 2 - \
				| bcftools norm --check-ref s --fasta-ref {config[ref_genome]} --output-type u - \
				| bcftools norm -d exact --output-type z - -o {output.vcf}
		fi
		sleep 2
		tabix -f -p vcf {output.vcf}
		vcffilter -f "QUAL > 15 & QA / AO > 15 & SAF > 0 & SAR > 0 & RPR > 0 & RPL > 0 & AO > 2 & DP > 3" {output.vcf} | bgzip -f > {output.filteredvcf}
		sleep 2
		tabix -f -p vcf {output.filteredvcf}
		module unload {config[freebayes_version]}
		module unload {config[vcflib_version]}
		module unload {config[vt_version]}
		module load {config[whatshap_version]}
		whatshap phase --reference {config[ref_genome]} --indels {output.filteredvcf} {input.bam} | bgzip -f > {output.phasedvcf}
		tabix -f -p vcf {output.phasedvcf}
		"""
#--skip-coverage 1000 added using the if statement on 1/3/2022, because some of WGS data failed when uysing --limit-coerage 500padded

# try rtg eval wihtout vt and see how it goes.
	# | vt decompose -s - \
	# | vt normalize -m -r {config[ref_genome]} - \
	#
#2/11/20: --min-coverage 3, UUAL > 0
#freebayes high sensitivity and benchmark: https://europepmc.org/article/PMC/6500473
# -g "GQ > 1"
#			| sed -e "s|1/.|0/1|" -e "s|./1|0/1|" \

#<5min and used < 32MB memory
rule cat_fbvcfs:
	input:
		vcf = chr_fbVCF_to_single_fbVCF,
		phasedvcf = chr_fbVCF_to_single_fbVCF_phased
	output:
		vcf = 'freebayes/vcf/{sample}.vcf.gz',
		phasedvcf = 'freebayes/vcf/{sample}.phased.vcf.gz',
		phasedvcf_tbi = 'freebayes/vcf/{sample}.phased.vcf.gz.tbi',
	threads: 8
	shell:
		"""
		module load {config[samtools_version]}
		bcftools concat --threads {threads} --output-type z {input.vcf} > {output.vcf}
		tabix -f -p vcf {output.vcf}
		bcftools concat --threads {threads} --output-type z {input.phasedvcf} > {output.phasedvcf}
		tabix -f -p vcf {output.phasedvcf}
		"""
		# bcftools concat --threads {threads} --output-type z {input.filteredvcf} > {output.filteredvcf}
		# tabix -f -p vcf {output.filteredvcf}

#genome: <30min, <2.5gb
rule automap_roh:
	input:
		vcf = 'freebayes/vcf/{sample}.vcf.gz'
	output:
		tsv = temp('AutoMap/{sample}/{sample}.HomRegions.tsv'),
		bed = temp('AutoMap/{sample}/{sample}.HomRegions.bed'),
		annotated = 'AutoMap/{sample}/{sample}.HomRegions.annot.tsv'
	shell:
		"""
		module load {config[samtools_version]} {config[bedtools_version]} {config[R_version]}
		if [[ {config[genomeBuild]} == "GRCh38" ]]; then
			ver=hg38
		else
			ver=hg19
		fi
		mkdir -p /lscratch/$SLURM_JOB_ID/AutoMap
		zcat {input.vcf} > /lscratch/$SLURM_JOB_ID/AutoMap/{wildcards.sample}.vcf
		bash /data/OGL/resources/git/AutoMap/AutoMap_v1.2.sh \
			--vcf /lscratch/$SLURM_JOB_ID/AutoMap/{wildcards.sample}.vcf \
			--out AutoMap --genome $ver --chrX
		echo "AutoMap1.2 done"
		if [[ $(grep -v ^# {output.tsv} | wc -l) == 0 ]]; then
			touch {output.bed}
			touch {output.annotated}
			echo "no ROH region detected."
		else
			grep -v ^# {output.tsv} | cut -f 1-3 > {output.bed}
			module load {config[annotsv_version]}
			AnnotSV -SVinputFile {output.bed} \
				-SVinputInfo 1 -genomeBuild {config[genomeBuild]} \
				-outputDir AutoMap/{wildcards.sample} \
				-outputFile AutoMap/{wildcards.sample}/{wildcards.sample}.annotated.tsv
			Rscript ~/git/NGS_genotype_calling/NGS_generic_OGL/automap.R {output.tsv} AutoMap/{wildcards.sample}/{wildcards.sample}.annotated.tsv {config[OGL_Dx_research_genes]} {output.annotated}
			rm AutoMap/{wildcards.sample}/{wildcards.sample}.annotated.tsv
		fi
		"""
# [ -s file ] test whether a file is present and with content
rule merge_freebayes:
	input:
		vcf = expand('freebayes/vcf/{sample}.phased.vcf.gz', sample=list(SAMPLE_LANEFILE.keys())),
		tbi = expand('freebayes/vcf/{sample}.phased.vcf.gz.tbi', sample=list(SAMPLE_LANEFILE.keys()))
	output:
		'freebayes/freebayes.merge.done.txt'
	threads: 16
	shell:
		"""
		module load {config[samtools_version]}
		case "{input.vcf}" in
			*\ *)
				bcftools merge --merge none --missing-to-ref --output-type z --threads {threads} {input.vcf} \
				> freebayes/{config[analysis_batch_name]}.freebayes.vcf.gz
				tabix -f -p vcf freebayes/{config[analysis_batch_name]}.freebayes.vcf.gz
				;;
			*)
				cp -p -l {input.vcf} freebayes/{config[analysis_batch_name]}.freebayes.vcf.gz
				cp -p -l {input.tbi} freebayes/{config[analysis_batch_name]}.freebayes.vcf.gz.tbi
				;;
		esac
		touch {output}
		"""
		# bcftools merge --merge none --output-type z --threads {threads} {input.vcf} \
		#  	> prioritization/{config[analysis_batch_name]}.freebayes.vcf.gz
#fast and only used 4 cpus, 100mg and 4 mins for 2 wgs data.
rule merge_dv_fb_vcfs:
	input:
		'deepvariant/deepvariantVcf.merge.done.txt',
		#'deepvariant/deepvariant.gvcf.merge.done.txt',
		'freebayes/freebayes.merge.done.txt'
	output:
		'prioritization/dv_fb.merge.done.txt'
	threads: 16
	shell:
		"""
		module load {config[samtools_version]}
		WORK_DIR=/lscratch/$SLURM_JOB_ID
		bcftools isec --threads {threads} -p $WORK_DIR --collapse none --no-version -Oz \
			deepvariant/{config[analysis_batch_name]}.dv.phased.vcf.gz \
			freebayes/{config[analysis_batch_name]}.freebayes.vcf.gz
		rm $WORK_DIR/0003.vcf* &
		bcftools annotate --threads {threads} --set-id 'dv_%CHROM\:%POS%REF\>%ALT' \
			--no-version $WORK_DIR/0000.vcf.gz -Oz -o $WORK_DIR/dv.vcf.gz && rm $WORK_DIR/0000.vcf* &
		bcftools annotate --threads {threads} --set-id 'fb_%CHROM\:%POS%REF\>%ALT' -x ^INFO/QA,FORMAT/RO,FORMAT/QR,FORMAT/AO,FORMAT/QA,FORMAT/GL \
			--no-version $WORK_DIR/0001.vcf.gz -Ou - \
			| sed 's#0/0:.:.:.#0/0:10:10:10,0#g' - \
			| bcftools +fill-tags - -Oz -o $WORK_DIR/fb.vcf.gz -- -t AC,AC_Hom,AC_Het,AN,AF && rm $WORK_DIR/0001.vcf* &
		bcftools annotate --threads {threads} --set-id 'dvFb_%CHROM\:%POS%REF\>%ALT' \
			--no-version $WORK_DIR/0002.vcf.gz -Oz -o $WORK_DIR/dvFb.vcf.gz
		rm $WORK_DIR/0002.vcf* &
		tabix -f -p vcf $WORK_DIR/dv.vcf.gz
		tabix -f -p vcf $WORK_DIR/fb.vcf.gz
		tabix -f -p vcf $WORK_DIR/dvFb.vcf.gz
		bcftools concat --threads {threads} -a --rm-dups none --no-version \
			$WORK_DIR/dvFb.vcf.gz $WORK_DIR/dv.vcf.gz $WORK_DIR/fb.vcf.gz -Oz \
			-o prioritization/{config[analysis_batch_name]}.vcf.gz
		tabix -f -p vcf prioritization/{config[analysis_batch_name]}.vcf.gz
		rm $WORK_DIR/dvFb.vcf.gz* $WORK_DIR/dv.vcf.gz* $WORK_DIR/fb.vcf.gz*
		if [[ {config[genomeBuild]} == "GRCh38" ]]; then
			module load {config[crossmap_version]}
			hg19refM=/data/OGL/resources/1000G_phase2_GRCh37/human_g1k_v37_decoyM.fasta
			hg19ref=/data/OGL/resources/1000G_phase2_GRCh37/human_g1k_v37_decoy.fasta
			crossmap vcf /data/OGL/resources/ucsc/hg38ToHg19.over.chain.gz \
				prioritization/{config[analysis_batch_name]}.vcf.gz \
				$hg19refM \
				$WORK_DIR/GRCh37.vcf
			sed -e 's/^chrM/MT/' -e 's/<ID=chrM/<ID=MT/' $WORK_DIR/GRCh37.vcf \
				| sed -e 's/^chr//' -e 's/<ID=chr/<ID=/' - \
			 	| bcftools norm --check-ref s --fasta-ref $hg19ref --output-type u - \
				| bcftools sort -m 60G -T $WORK_DIR/ -Ou - \
				| bcftools norm --threads $(({threads}-4)) -d exact --output-type z - -o prioritization/{config[analysis_batch_name]}.GRCh37.vcf.gz
			tabix -f -p vcf prioritization/{config[analysis_batch_name]}.GRCh37.vcf.gz
		fi
		touch {output}
		"""


#sort necessary before mark_dup? it was sorted during the merge lane_bam step.
rule picard_clean_sam:
# "Soft-clipping beyond-end-of-reference alignments and setting MAPQ to 0 for unmapped reads"
	input:
		'sample_bam/chr_split/{sample}/{sample}__{chr}.bam'
	output:
		temp('sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.bam')
	threads: 2
	shell:
		"""
		module load {config[picard_version]}
		java -Xmx60g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
			CleanSam \
			TMP_DIR=/lscratch/$SLURM_JOB_ID \
			INPUT={input} \
			OUTPUT={output}
		"""

rule picard_fix_mate_information:
# "Verify mate-pair information between mates and fix if needed."
# also coord sorts
	input:
		'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.bam'
	output:
		temp('sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.bam')
	threads: 2
	shell:
		"""
		module load {config[picard_version]}
		java -Xmx60g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
		FixMateInformation \
			SORT_ORDER=coordinate \
			INPUT={input} \
			OUTPUT={output}
		"""

rule picard_mark_dups:
# Mark duplicate reads
	input:
		'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.bam'
	output:
		bam = temp('sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.bam'),
		bai = temp('sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.bai'),
		metrics = 'GATK_metrics/{sample}__{chr}.markDup.metrics'
	threads: 2
	shell:
		"""
		module load {config[picard_version]}
		java -Xmx60g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
			MarkDuplicates \
			INPUT={input} \
			OUTPUT={output.bam} \
			METRICS_FILE={output.metrics} \
			CREATE_INDEX=true
		"""



rule gatk_realigner_target:
# identify regions which need realignment
	input:
		bam = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.bam',
		bai = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.bai'
	output:
		temp('sample_bam/chr_split/{sample}/{sample}__{chr}.forIndexRealigner.intervals')
	threads: 2
	shell:
		"""
		module load {config[gatk_version]}
		GATK -p {threads} -m 8g RealignerTargetCreator  \
			-R {config[ref_genome]}  \
			-I {input.bam} \
			--known {config[1000g_indels]} \
			--known {config[mills_gold_indels]} \
			-o {output}
		"""

rule gatk_indel_realigner:
# realigns indels to improve quality
	input:
		bam = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.bam',
		bai = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.bai',
		targets = 'sample_bam/chr_split/{sample}/{sample}__{chr}.forIndexRealigner.intervals'
	output:
		temp('sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.gatk_realigner.bam')
	threads: 2
	shell:
		"""
		module load {config[gatk_version]}
		GATK -p {threads} -m 8g IndelRealigner \
			-R {config[ref_genome]} \
			-I {input.bam} \
			--knownAlleles {config[1000g_indels]} \
			--knownAlleles {config[mills_gold_indels]} \
			-targetIntervals {input.targets} \
			-o {output}
		"""

rule gatk_base_recalibrator:
# recalculate base quality scores
	input:
		'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.gatk_realigner.bam'
	output:
		'GATK_metrics/{sample}__{chr}.recal_data.table1'
	threads: 2
	shell:
		"""
		module load {config[gatk_version]}
		GATK -p {threads} -m 15g BaseRecalibrator  \
			-R {config[ref_genome]} \
			-I {input} \
			--knownSites {config[1000g_indels]} \
			--knownSites {config[mills_gold_indels]} \
			--knownSites {config[dbsnp_var]} \
			-o {output}
		"""

rule gatk_print_reads:
# print out new bam with recalibrated scoring
	input:
		bam = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.gatk_realigner.bam',
		bqsr = 'GATK_metrics/{sample}__{chr}.recal_data.table1'
	output:
		temp('sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.gatk_realigner.recalibrated.bam')
	threads: 2
	shell:
		"""
		module load {config[gatk_version]}
		GATK -p {threads} -m 15g PrintReads \
			-R {config[ref_genome]} \
			-I {input.bam} \
			-BQSR {input.bqsr} \
			-o {output}
		"""

rule gatk_base_recalibrator2:
# recalibrate again
	input:
		bam = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.gatk_realigner.bam',
		bqsr = 'GATK_metrics/{sample}__{chr}.recal_data.table1'
	output:
		'GATK_metrics/{sample}__{chr}.recal_data.table2'
	threads: 2
	shell:
		"""
		module load {config[gatk_version]}
		GATK -p {threads} -m 15g BaseRecalibrator  \
			-R {config[ref_genome]} \
			-I {input.bam} \
			--knownSites {config[1000g_indels]} \
			--knownSites {config[mills_gold_indels]} \
			--knownSites {config[dbsnp_var]} \
			-BQSR {input.bqsr} \
			-o {output}
			"""

rule gatk_analyze_covariates:
	input:
		one = 'GATK_metrics/{sample}__{chr}.recal_data.table1',
		two = 'GATK_metrics/{sample}__{chr}.recal_data.table2'
	output:
		'GATK_metrics/{sample}__{chr}.BQSRplots.pdf'
	threads: 2
	shell:
		"""
		module load {config[gatk_version]}
		GATK -p {threads} -m 8g AnalyzeCovariates \
			-R {config[ref_genome]} \
			-before {input.one} \
			-after {input.two} \
			-plots {output}
		"""

rule gatk_haplotype_caller:
# call gvcf
	input:
		bam = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.gatk_realigner.recalibrated.bam',
		bqsr = 'GATK_metrics/{sample}__{chr}.recal_data.table1'
	output:
		temp('gvcfs/chr_split/{sample}/{sample}__{chr}.g.vcf.gz')
	threads: 2
	shell:
		"""
		module load {config[gatk_version]}
		GATK -p {threads} -m 8g HaplotypeCaller \
			-R {config[ref_genome]} \
			-I {input.bam} \
			--emitRefConfidence GVCF \
			-BQSR {input.bqsr} \
			-o {output}
		"""

# if config['cram']  == 'TRUE':
# 	rule picard_merge_bams:
# # merge chr split bams into one bam per sample
# 		input:
# 			chr_bam_to_single_bam
# 		output:
# 			temp('sample_bam/{sample}.recalibrated.bam')
# 		threads: 2
# 		shell:
# 			"""
# 			module load {config[picard_version]}
# 			cat_inputs_i=""
# 			for bam in {input}; do
# 				cat_inputs_i+="I=$bam "; done
# 			java -Xmx15g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
# 				MergeSamFiles \
# 				$cat_inputs_i \
# 				O={output}
# 			"""
# else:
# 	rule picard_merge_bams_index:
# # merge chr split bams into one bam per sample
# 		input:
# 			chr_bam_to_single_bam
# 		output:
# 			bam = 'sample_bam/{sample}.recalibrated.bam',
# 			bai1 = 'sample_bam/{sample}.recalibrated.bai',
# 			bai2 = 'sample_bam/{sample}.recalibrated.bam.bai'
# 		threads: 2
# 		shell:
# 			"""
# 			module load {config[picard_version]}
# 			cat_inputs_i=""
# 			for bam in {input}; do
# 				cat_inputs_i+="I=$bam "; done
# 			java -Xmx15g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
# 				MergeSamFiles \
# 				SORT_ORDER=coordinate \
# 				CREATE_INDEX=true \
# 				$cat_inputs_i \
# 				O={output.bam}
# 			cp {output.bai1} {output.bai2}
# 			"""
#java -Xmx15g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
#	BuildBamIndex \
#	INPUT={output.bam} \
#	OUTPUT={output.bai}


rule picard_merge_gvcfs:
# merge chr split gvcf back into one gvcf per sample
	input:
		chr_GVCF_to_single_GVCF
	output:
		'gvcfs/{sample}.g.vcf.gz'
	threads: 2
	shell:
		"""
		module load {config[picard_version]}
		cat_inputs_i=""
		for gvcf in {input}; do
			cat_inputs_i+="I=$gvcf "; done
		java -Xmx15g -XX:+UseG1GC -XX:ParallelGCThreads={threads} -jar $PICARD_JAR \
			MergeVcfs \
			$cat_inputs_i \
			O={output}
		"""

rule multiqc_gatk:
# run multiqc on recalibrator metrics
	input:
		expand('GATK_metrics/{sample}__{chr}.recal_data.table1',sample=list(SAMPLE_LANEFILE.keys()), chr=CHRS),
		expand('GATK_metrics/{sample}__{chr}.recal_data.table2', sample=list(SAMPLE_LANEFILE.keys()), chr=CHRS)
	output:
		directory('GATK_metrics/multiqc_report')
	shell:
		"""
		module load multiqc
		multiqc -f -o {output} GATK_metrics
		"""


##freebayes
#freebayes-parallel <(fasta_generate_regions.py ref.fa.fai 100000) 36 -f ref.fa aln.bam >out.vcf"


# rule scramble:
# 	input:
# 		bam = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.bam',
# 		bai = 'sample_bam/chr_split/{sample}/{sample}__{chr}.CleanSam.sorted.markDup.bai'
# 	output:
# 		cluster = temp('scramble/chr_split/{sample}/{sample}__{chr}.cluster.txt'),
# 		mei = 'scramble/chr_split/{sample}/{sample}__{chr}.mei.txt'
# 	shell:
# 		"""
# 		module load scramble
# 		scramble cluster_identifier {input.bam} > {output.cluster}
# 		scramble Rscript --vanilla /app/cluster_analysis/bin/SCRAMble-MEIs.R \
# 			--out-name ${{PWD}}/{output.mei} \
# 			--cluster-file ${{PWD}}/{output.cluster} \
# 			--install-dir /app/cluster_analysis/bin \
# 			--mei-refs /app/cluster_analysis/resources/MEI_consensus_seqs.fa
# 		"""
#
# #localrules: scramble_annotation
# rule scramble_annotation:
# 	input:
# 		mei = 'scramble/chr_split/{sample}/{sample}__{chr}.mei.txt'
# 	output:
# 		avinput = temp('scramble/chr_split/{sample}/{sample}__{chr}.avinput'),
# 		annovar = temp('scramble/chr_split/{sample}/{sample}__{chr}.hg19_multianno.txt'),
# 		annovarR = temp('scramble/chr_split/{sample}/{sample}__{chr}.forR.txt'),
# 		anno = 'scramble/chr_split/{sample}/{sample}__{chr}.scramble.tsv'
# 	shell:
# 		"""
# 		module load {config[R_version]}
# 		module load {config[annovar_version]}
# 		if [[ $(wc -l {input.mei} | cut -d " " -f 1) == 1 ]]
# 		then
# 			touch {output.avinput}
# 			touch {output.annovar}
# 			touch {output.annovarR}
# 			touch {output.anno}
# 		else
# 			cut -f 1 {input.mei} | awk -F ":" 'BEGIN{{OFS="\t"}} NR>1 {{print $1,$2,$2,"0","-"}}' > {output.avinput}
# 			table_annovar.pl {output.avinput} \
# 				$ANNOVAR_DATA/hg19 \
# 				-buildver hg19 \
# 				-remove \
# 				-out scramble_anno/{wildcards.sample} \
# 				--protocol refGene \
# 				-operation  g \
# 				--argument '-splicing 100 -hgvs' \
# 				--polish -nastring . \
# 				--thread 1
# 			awk -F"\t" 'BEGIN{{OFS="\t"}} NR==1 {{print "Func_refGene","Gene","Intronic","AA"}} NR>1 {{print $6,$7,$8,$10}}' {output.annovar} | paste {input.mei} - > {output.annovarR}
# 			Rscript /home/$USER/git/NGS_genotype_calling/NGS_generic_OGL/scramble_CHRanno.R {output.annovarR} {config[SCRAMBLEdb]} {config[OGL_Dx_research_genes]} {config[HGMDtranscript]} {output.anno} {wildcards.sample}
# 		fi
# 		"""
#
# localrules: cat_scramble
# rule cat_scramble:
# 	input:
# 		tsv = chr_scramble_to_single_scramble
# 	output:
# 		tsv = temp('scramble_anno/{sample}.scramble.tsv'),
# 		xlsx = 'scramble_anno/{sample}.scramble.xlsx'
# 	shell:
# 		"""
# 		module load {config[R_version]}
# 		cat {input} | grep -v "^eyeGene" > {output.tsv}
# 		sed -i "1 i\eyeGene\tInsertion\tMEI_Family\tInsertion_Direction\tClipped_Reads_In_Cluster\tAlignment_Score\tAlignment_Percent_Length\tAlignment_Percent_Identity\tClipped_Sequence\tClipped_Side\tStart_In_MEI\tStop_In_MEI\tpolyA_Position\tpolyA_Seq\tpolyA_SupportingReads\tTSD\tTSD_length\tpanel_class\tGene\tIntronic\tAA\tclassification\tpopAF\tsample\tnote" {output.tsv}
# 		Rscript /home/$USER/git/NGS_genotype_calling/NGS_generic_OGL/scramble_sortanno.R {output.tsv} {output.xlsx}
# 		"""
