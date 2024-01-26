#!/bin/bash
#$1 version
#$2 message, quotation mark for sentence
echo $1 "$2"
git add --all
git commit -a -m "$2"
git tag -a $1 -m "$2"
git log | head -n 5 > /data/OGL/resources/NGS_genotype_calling.git.log
git tag | tail -n 1 >> /data/OGL/resources/NGS_genotype_calling.git.log
git push origin $1
