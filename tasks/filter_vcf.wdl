task filter_vcf {
	File vcf
	File bed
	File benchmark_region
	String project
	String sample = basename(vcf,".vcf")
	String docker
	String cluster_config
	String disk_size
	
	command <<<

		cat ${vcf} | grep '#' > header
		cat ${vcf} | grep -v '#' > body
		cat body | grep -w '^chr1\|^chr2\|^chr3\|^chr4\|^chr5\|^chr6\|^chr7\|^chr8\|^chr9\|^chr10\|^chr11\|^chr12\|^chr13\|^chr14\|^chr15\|^chr16\|^chr17\|^chr18\|^chr19\|^chr20\|^chr21\|^chr22\|^chrX' > body.filtered
		cat header body.filtered > ${sample}.filtered.vcf
		bedtools intersect -a ${sample}.filtered.vcf -b ${bed} > body.bed.filtered
		cat header body.bed.filtered > ${project}.${sample}.chrom.bed.filtered.vcf
		bedtools intersect -a ${benchmark_region} -b ${bed} > benchmark_region_query_bed.bed

	>>>

	runtime {
		docker:docker
		cluster: cluster_config
		systemDisk: "cloud_ssd 40"
		dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/"
	}
	output {
		File filtered_vcf = "${project}.${sample}.chrom.bed.filtered.vcf"
		File filtered_bed = "benchmark_region_query_bed.bed"
	}
}