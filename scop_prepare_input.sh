#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/scop_prepare_input.log
#BSUB -R "span[hosts=1]"
#BSUB -R haswell
#BSUB -m hh
#BSUB -R cbscratch
#BSUB -J scop_prepare_input

source ./paths.sh
source ~/.bashrc

echo "scop_prepare_input: Removing old scop.fas and running to create an up-to-date fasta file ..."
mkdir -p ${scop_dir}

# work in temp directory
rm -rf ${scop_build_dir}
mkdir -p ${scop_build_dir}

echo "scop_prepare_input: Converting fasta file to ffdata, ffindex."
rm -f ${scop_dir}/scop100_fasta.ff{data,index}
ffindex_from_fasta -s ${scop_dir}/scop100_fasta.ff{data,index} ${scop_dir}/scop100.fas

echo "scop_prepare_input: Starting mmseqs to cluster sequences from scop100.fas (-c 0.9 --min-seq-id 0.4|0.7|0.95) ..."
mmseqs createdb ${scop_dir}/scop100.fas ${scop_dir}/scop100
for id in 40 70 90 95;
do
  rm -rf ${scop_dir}/scop${id}_clu.tsv ${scop_build_dir}/todo_${id}_files.dat ${scop_build_dir}/clustering${id}
  mkdir -p ${scop_build_dir}/clustering${id}
  mmseqs cluster ${scop_dir}/scop100 ${scop_build_dir}/scop${id}_clu ${scop_build_dir}/clustering${id} -c 0.9 --min-seq-id $(echo "scale=2; ${id} / 100" | bc)
  mmseqs createtsv ${scop_dir}/scop100 ${scop_dir}/scop100 ${scop_build_dir}/scop${id}_clu ${scop_dir}/scop${id}_clu.tsv

  cut -f1 ${scop_dir}/scop${id}_clu.tsv | sort | uniq -u > ${scop_build_dir}/todo_${id}_files.dat
done

#build selected fasta sequences ffindex
ln -s ${scop_dir}/scop100_fasta.ffdata ${scop_build_dir}/selected_scop_fasta.ffdata
cp ${scop_dir}/scop100_fasta.ffindex ${scop_build_dir}/selected_scop_fasta.ffindex

cut -f1 ${scop_dir}/scop100_fasta.ffindex > ${scop_build_dir}/fasta_files.dat
cat ${scop_build_dir}/todo_*_files.dat | sort | uniq > ${scop_build_dir}/todo_files.dat
cat ${scop_build_dir}/fasta_files.dat ${scop_build_dir}/todo_files.dat | sort | uniq -u > ${scop_build_dir}/not_todo_files.dat
ffindex_modify -s -u -f ${scop_build_dir}/not_todo_files.dat ${scop_build_dir}/selected_scop_fasta.ffindex

