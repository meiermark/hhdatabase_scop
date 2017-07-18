#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 160
#BSUB -a openmpi
#BSUB -o /usr/users/jsoedin/jobs/scop_hhblits.log
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J scop_hhblits
#BSUB -m hh
##BSUB -w "done(scop_prepare_input)"

source /etc/profile
source $HOME/.bashrc

source paths.sh

rm -f ${scop_build_dir}/scop_a3m_without_ss.ff{data,index}*
mpirun -np 160 ffindex_apply_mpi ${scop_build_dir}/selected_scop_fasta.ff{data,index} -i ${scop_build_dir}/scop_a3m.ffindex -d ${scop_build_dir}/scop_a3m.ffdata -- hhblits -i stdin -oa3m stdout -o /dev/null -cpu 1 -d ${uniprot} -n 3 -v 0


