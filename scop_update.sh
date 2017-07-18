#!/bin/bash

source /etc/profile
source ~/.bashrc

cd ${HOME}/git/hhdatabase_scop
source ./paths.sh

mkdir -p ${scop_dir}
export scop_lock_file=${scop_dir}/lock_pdb70.txt

if [ -e ${scop_lock_file} ] && kill -0 `cat ${scop_lock_file}`; then
  echo "already running"
  exit
fi

rm -f ${HOME}/jobs/scop*.log

rm -f ${scop_dir}/scop100.fas
#TODO find newest scope release automatically
curl -o ${scop_dir}/scop100.fas http://scop.berkeley.edu/downloads/scopeseq-2.06/astral-scopedom-seqres-gd-all-2.06-stable.fa
sed -i -r 's/^([a-z].*)/\U\1/' ${scop_dir}/scop100.fas

bsub < ./scop_prepare_input.sh
#bsub < ./scop_hhblits.sh

#depends on hhblits
#bsub < ./scop_addss.sh
#bsub < ./scop_cstranslate.sh
#bsub < ./scop_cstranslate_old.sh

#depends on addss
#bsub < ./scop_hhmake.sh

#depends on hhmake cstranslate cstranslate_old
#bsub < ./scop_finalize.sh

