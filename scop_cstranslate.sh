#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/scop_cstranslate.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J scop_cstranslate
#BSUB -m hh
##BSUB -w "done(scop_hhblits)"

source /etc/profile
source $HOME/.bashrc

source paths.sh

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${scop_build_dir}/scop_a3m
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

cstranslate -A ${HHLIB}/data/cs219.lib -D ${HHLIB}/data/context_data.lib -x 0.3 -c 4 -f -i ${input} -o ${MYLOCAL}/scop_cs219 -I a3m -b
ffindex_build -as ${MYLOCAL}/scop_cs219.ff{data,index}

rm -f ${scop_build_dir}/scop_cs219.ff{data,index}
cp ${MYLOCAL}/scop_cs219.ff{data,index} ${scop_build_dir}/
