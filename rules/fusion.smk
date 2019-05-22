rule pizzly:
    input:
        "kallisto/{sample}-{unit}"
    output:
        directory("pizzly/{sample}-{unit}")
        #"pizzly/{sample}-{unit}/output.json",
        #"pizzly/{sample}-{unit}/output.fusions.fasta"
    log:
        "logs/pizzly/{sample}-{unit}/index.log"
    params:
        fasta=config["ref"]["transcriptome"]
        gtf=config["ref"]["gtf"],
        extra=config["params"]["pizzly"]
    conda:
        "../envs/pizzly.yaml"
    shell:
        "pizzly --gtf {params.gtf} --cache {params.gtf}.cache.txt --fasta {params.fasta} --output {output} {input}/fusion.txt 2> {log}"

rule append_index:
    input:
        fasta=config["ref"]["transcriptome"],
        dir="pizzly/{sample}-{unit}"
    output:
        fasta="pizzly/{sample}-{unit}/transcripts_with_fusions.fasta.gz",
        idx="pizzly/{sample}-{unit}/transcripts_with_fusions.kidx"
    log:
        "logs/kallisto/fusion_index/{sample}-{unit}.log"
    conda:
        "../envs/kallisto.yaml"
    shell:
        "cat {input.fasta} {input.dir}/output.fusions.fasta > {output.fasta} && "
        "kallisto index -k 31 -i {output.idx} {output.fasta}"

rule requant_kallisto:
    input:
        fq=get_trimmed
        idx="pizzly/{sample}-{unit}/transcripts_with_fusions.kidx"
    output:
        directory("kallisto_fusion_requant/{sample}-{unit}")
    log:
        "logs/kallisto/fusion_requant/{sample}-{unit}.log"
    params:
        extra=config["params"]["kallisto"]
    conda:
        "../envs/kallisto.yaml"
    shell:
        "kallisto quant -i {input.idx} -o {output} "
        "{params.extra} {input.fq} 2> {log}"
