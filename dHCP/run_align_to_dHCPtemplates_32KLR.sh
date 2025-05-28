#!/bin/bash -l
#SBATCH --partition=cpu
#SBATCH --time=0-4:00
#SBATCH --nodes=1
#SBATCH --mem=2048
#SBATCH --ntasks=4
#SBATCH --job-name=registration_resample
#SBATCH --array=1-874


topdir="/scratch_tmp/prj/cortical_imaging/kaili_tmp/dHCP_DL/dHCP_surface_fsLR_clean874"
subject_list="/scratch_tmp/prj/cortical_imaging/kaili_tmp/dHCP_DL/subject_scanage_874.txt"
templateage=40
templatespherepath="/scratch_tmp/prj/cortical_imaging/kaili_tmp/dHCP_DL/templates/LR_vertexCorre_templates"
tempTotemp="/scratch_tmp/prj/cortical_imaging/kaili_tmp/dHCP_DL/templates/template_to_template/LR_templates"
pre_rotation="/scratch_tmp/prj/cortical_imaging/kaili_tmp/dHCP_DL/prerotation"
config="/scratch_tmp/prj/cortical_imaging/kaili_tmp/templates_conf/config_subject_to_40_week_template_3rd_release"


while IFS= read -r line; do

    subjid=$(echo "$line" | awk '{print $1}')
    age=$(echo "$line" | awk '{printf "%.0f\n", $2}')

    if (( age < 28 )); then
        age=28
    fi

    /scratch_tmp/prj/cortical_imaging/kaili_tmp/dHCP_DL/align_to_dHCPtemplates_32KLR.sh ${topdir} ${subjid} ${age} ${templateage} ${templatespherepath} ${tempTotemp} ${pre_rotation} ${config}


done < <(sed -n "${SLURM_ARRAY_TASK_ID}p" $subject_list)
