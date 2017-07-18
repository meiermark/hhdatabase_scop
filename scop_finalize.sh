#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 1
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/scop_finalize.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J scop_finalize
#BSUB -m hh
##BSUB -w "done(scop_hhmake) && done(scop_cstranslate) && done(scop_cstranslate_old)"

source /etc/profile
source $HOME/.bashrc

source paths.sh

cut -f1 ${scop_dir}/scop100_fasta.ffindex > ${scop_build_dir}/scop100.dat
cd ${scop_dir}

for thresh in 40 70 90 95;
do
  ## Copy from build to final directory
  for type in a3m hhm cs219;
  do
    # Copy raw files
    rm -f ${scop_dir}/scop${thresh}_${type}.ff{data,index}
    cp -f ${scop_build_dir}/scop_${type}.ffindex ${scop_dir}/scop${thresh}_${type}.ffindex
    cp -f ${scop_build_dir}/scop_${type}.ffdata ${scop_dir}/scop${thresh}_${type}.ffdata

    # Remove unnecessary files from ffindex
    cat ${scop_build_dir}/scop100.dat ${scop_build_dir}/todo_${thresh}_files.dat | sort | uniq -u > ${scop_build_dir}/rm_${thresh}_files.dat
    ffindex_modify -u -f ${scop_build_dir}/rm_${thresh}_files.dat ${scop_dir}/scop${thresh}_${type}.ffindex

    # Optimize -- remove unnecessary files from ffdata
    ffindex_build -as -d ${scop_dir}/scop${thresh}_${type}.ffdata -i ${scop_dir}/scop${thresh}_${type}.ffindex ${scop_dir}/scop${thresh}_${type}_opt.ff{data,index}

    # Overwrite unoptimized databases with optimized databases
    mv -f ${scop_dir}/scop${thresh}_${type}_opt.ffdata ${scop_dir}/scop${thresh}_${type}.ffdata
    mv -f ${scop_dir}/scop${thresh}_${type}_opt.ffindex ${scop_dir}/scop${thresh}_${type}.ffindex
  done

  ##sort hhms and a3m according to sequence length
  sort -k 3 -n ${scop_dir}/scop${thresh}_cs219.ffindex | cut -f1 > ${scop_build_dir}/sort_by_length.dat
  for type in a3m hhm;
  do
    ffindex_order ${scop_build_dir}/sort_by_length.dat ${scop_dir}/scop${thresh}_${type}.ffdata ${scop_dir}/scop${thresh}_${type}.ffindex ${scop_dir}/scop${thresh}_${type}_opt.ffdata ${scop_dir}/scop${thresh}_${type}_opt.ffindex

    mv -f ${scop_dir}/scop${thresh}_${type}_opt.ffdata ${scop_dir}/scop${thresh}_${type}.ffdata
    mv -f ${scop_dir}/scop${thresh}_${type}_opt.ffindex ${scop_dir}/scop${thresh}_${type}.ffindex
  done

  rm -f scop${thresh}.tgz md5sum
  md5sum scop${thresh}_{a3m,hhm,cs219}.ff{data,index} > md5sum

  month=$(date +"%b")
  day=$(date +"%d")
  year=$(date +"%y")
  tar_name=scop${thresh}_${day}${month}${year}.tgz

  tar -zcvf ${tar_name} md5sum scop${thresh}_{a3m,hhm,cs219}.ff{data,index}
  chmod og+r ${tar_name}

  ssh compbiol@login.gwdg.de "mv -f /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs/scop${thresh}*.tgz /usr/users/a/soeding"
  scp ${tar_name} compbiol@login.gwdg.de:/usr/users/compbiol
  ssh compbiol@login.gwdg.de "mv /usr/users/compbiol/${tar_name} /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs"
  ssh compbiol@login.gwdg.de "ln -fs /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs/${tar_name} /usr/users/compbiol/current_scop${thresh}.tgz"

  rm -f ${tar_name}
done

