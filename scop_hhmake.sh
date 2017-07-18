#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/scop_hhmake.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J scop_hhmake
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

mpirun -np 16 ffindex_apply_mpi ${input}.ff{data,index} -d ${MYLOCAL}/scop_hhm.ffdata -i ${MYLOCAL}/scop_hhm.ffindex -- hhmake -i stdin -o stdout -v 0

ffindex_build -as ${MYLOCAL}/scop_hhm.ff{data,index}
rm -f ${scop_build_dir}/scop_hhm.ff{data,index}
cp ${MYLOCAL}/scop_hhm.ff{data,index} ${scop_build_dir}/
