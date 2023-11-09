#!/bin/bash
#SBATCH -A feczk001
#SBATCH --time=0:05:00
#SBATCH --ntasks=1
#SBATCH --mem=2g
#SBATCH --tmp=2g
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=and02709@umn.edu

# *** Make sure you have a new enough getopt to handle long options (see the man page)
getopt -T &>/dev/null
if [[ $? -ne 4 ]]; then echo "Getopt is too old!" >&2 ; exit 1 ; fi

declare {setwd}
OPTS=$(getopt -u -o '' -a --longoptions 'setwd:,' -n "$0" -- "$@")
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
	--)
        	shift
        	break
        	;;
    *)
  esac
done
module load R/4.3.0-openblas
Rscript ${setwd}cv_analysis_SGSPCA.R $setwd
exit 0
