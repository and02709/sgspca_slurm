#!/bin/bash

# *** Make sure you have a new enough getopt to handle long options (see the man page)
getopt -T &>/dev/null
if [[ $? -ne 4 ]]; then echo "Getopt is too old!" >&2 ; exit 1 ; fi

declare {setwd,memarg,temparg,timearg,xfile,yfile,npc,nfolds,groups,gparams,alphas,kernel,niter,trace,balance}
OPTS=$(getopt -u -o '' -a --longoptions 'setwd:,memarg:,temparg:,timearg:,xfile:,yfile:,npc:,nfolds:,groups:,gparams:,alphas:,kernel:,niter:,trace:,balance:' -n "$0" -- "$@")
    # *** Added -o '' ; surrounted the longoptions by ''
if [[ $? -ne 0 ]] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
    # *** This has to be right after the OPTS= assignment or $? will be overwritten

set -- $OPTS
    # *** As suggested by chepner

while true; do
  case $1 in
	--setwd )
		setwd=$2
		shift 2
		;;
	--memarg )
		memarg=$2
		shift 2
		;;
	--temparg )
		temparg=$2
		shift 2
		;;
	--timearg )
		timearg=$2
		shift 2
		;;
	--xfile )
        	xfile=$2
        	shift 2
        	;;
	--yfile )
        	yfile=$2
        	shift 2
        	;;
	--npc )
        	npc=$2
        	shift 2
        	;;
	--nfolds )
        	nfolds=$2
        	shift 2
        	;;
	--groups )
		groups=$2
		shift 2
		;;
	--gparams )
		gparams=$2
		shift 2
		;;
	--alphas )
		alphas=$2
		shift 2
		;;
	--kernel )
		kernel=$2
		shift 2
		;;
	--niter )
		niter=$2
		shift 2
		;;
	--trace )
		trace=$2
		shift 2
		;;
	--balance )
		balance=$2
		shift 2
		;;
	--)
        	shift
        	break
        	;;
    *)
  esac
done
echo "setwd: $setwd"
echo "xfile: $xfile"
echo "yfile: $yfile"
echo "npc: $npc"
echo "nfolds: $nfolds"
echo "groups: $groups"
echo "gparams: $gparams"
echo "alphas: $alphas"
echo "kernel: $kernel"
echo "niter: $niter"
echo "trace: $trace"
echo "balance: $balance"
module load R/4.3.0-openblas
mkdir ${setwd}temp
mkdir ${setwd}temp/sbatch_logs
sbatch --time $timearg --mem $memarg --tmp $temparg --job-name data_partition --output ${setwd}temp/sbatch_logs/data_partition.out --error ${setwd}temp/sbatch_logs/data_partition.err ${setwd}prelim_data_sgspca_r.sh --setwd $setwd --xfile $xfile --yfile $yfile --npc $npc --nfolds $nfolds --groups $groups --gparams $gparams --alphas $alphas --kernel $kernel --niter $niter --trace $trace --balance $balance
tempvar=temp/param.txt
paramdir=$setwd$tempvar
until [ -f $paramdir ]
do
sleep 1
done
totalrows=$(< $paramdir wc -l)
echo "total rows: $totalrows"
numrows=$(expr $totalrows - 1)
echo "parameter rows: $numrows"
indexarray=$(seq -s ' ' 1 $numrows)
#echo "array: $indexarray"
mkdir ${setwd}temp/cv_outputs
for i in $indexarray
do
sbatch --time $timearg --mem $memarg --tmp $temparg --job-name cv_job_${i} --output ${setwd}/temp/sbatch_logs/cv_job_${i}.out --error ${setwd}/temp/sbatch_logs/cv_job_${i}.err ${setwd}cv_partition_sgspca.sh --setwd $setwd --index $i --npc $npc --nfolds $nfolds --kernel $kernel --niter $niter --trace $trace
echo "Submitted Job: $i"
sleep 0.1
done

exit 0
