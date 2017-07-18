#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/pdb70_cstranslate_old.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pdb70_cstranslate_old
#BSUB -m hh
#BSUB -w "done(pdb70_hhblits)"

source /etc/profile
source $HOME/.bashrc

source paths.sh

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${pdb70_build_dir}/pdb70_a3m_without_ss
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

cstranslate -A ${HHLIB}/data/cs219.lib -D ${HHLIB}/data/context_data.lib -x 0.3 -c 4 -f -i ${input} -o ${MYLOCAL}/pdb70_cs219_old -I a3m

ffindex_build -as ${MYLOCAL}/pdb70_cs219_old.ff{data,index}
rm -f ${pdb70_build_dir}/pdb70_cs219_old.ff{data,index}
cp ${MYLOCAL}/pdb70_cs219_old.ff{data,index} ${pdb70_build_dir}/
