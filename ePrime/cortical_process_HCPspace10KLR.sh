#!/bin/bash -l
#SBATCH --partition=cpu
#SBATCH --time=0-1:00
#SBATCH --nodes=1
#SBATCH --mem=2048
#SBATCH --ntasks=4
#SBATCH --job-name=registration_resample
#SBATCH --array=1-444


# Define the base directory and destination paths
base_dir="/scratch/prj/cortical_imaging/kaili/eprime/ePrime_T2dhcpdl_fs"
subject_list="/scratch/prj/cortical_imaging/kaili/eprime/eprime444_scanage_before45.txt"


sphere_temp="/scratch/prj/cortical_imaging/kaili/icospheres"


# Read each subject ID from the file
while IFS= read -r line; do

    subject_id=$(echo "$line" | awk '{print $1}')

    echo "Processing ${subject_id}..."

    # Define subject-specific paths
    src_dir="${base_dir}/${subject_id}"
    dst_dir="${base_dir}/${subject_id}/10KLR_HCPspace"

    # Create destination directory if it doesn't exist
    mkdir -p "${dst_dir}"

    
    wb_command -surface-sphere-project-unproject \
     "${src_dir}/32KLR_dHCP40space/${subject_id}_hemi-left_from-native-to-LR.week40_32k.sphere.reg.surf.gii" \
     "/scratch/prj/cortical_imaging/kaili/dHCP_DLtemplates/LR_vertexCorre_templates/week40_left_LR.32k.sphere.surf.gii" \
     "/scratch/prj/cortical_imaging/kaili/dHCP_DLtemplates/template_to_template/LR_templates/dHCPweek40LR_HCP.left.sphere.reg.surf.gii" \
     "${dst_dir}/${subject_id}_hemi-left_from-native-to-HCPspace.sphere.reg.surf.gii"


    wb_command -surface-sphere-project-unproject \
     "${src_dir}/32KLR_dHCP40space/${subject_id}_hemi-right_from-native-to-LR.week40_32k.sphere.reg.surf.gii" \
     "/scratch/prj/cortical_imaging/kaili/dHCP_DLtemplates/LR_vertexCorre_templates/week40_right_LR.32k.sphere.surf.gii" \
     "/scratch/prj/cortical_imaging/kaili/dHCP_DLtemplates/template_to_template/LR_templates/dHCPweek40LR_HCP.right.sphere.reg.surf.gii" \
     "${dst_dir}/${subject_id}_hemi-right_from-native-to-HCPspace.sphere.reg.surf.gii"

    
    for hemi in left right; do
        for anat in pial wm midthickness inflated vinflated; do

            # resample surface
            wb_command -surface-resample "${src_dir}/${subject_id}_hemi-${hemi}_${anat}.surf.gii" "${dst_dir}/${subject_id}_hemi-${hemi}_from-native-to-HCPspace.sphere.reg.surf.gii" "${sphere_temp}/ico-5_${hemi}.surf.gii" BARYCENTRIC "${dst_dir}/${subject_id}_hemi-${hemi}_${anat}.10k.surf.gii"

        done
    done


    for hemi in left right; do
        for anat in pial wm midthickness; do

            # calculate vertex areas from 10k surface
            wb_command -surface-vertex-areas "${dst_dir}/${subject_id}_hemi-${hemi}_${anat}.10k.surf.gii" "${dst_dir}/${subject_id}_hemi-${hemi}_${anat}_va.10k.shape.gii"

        done
    done




    for hemi in left right; do
        for metrics in sulc curv thickness; do

            # resample metrics
            wb_command -metric-resample "${src_dir}/${subject_id}_hemi-${hemi}_${metrics}.shape.gii" "${dst_dir}/${subject_id}_hemi-${hemi}_from-native-to-HCPspace.sphere.reg.surf.gii" "${sphere_temp}/ico-5_${hemi}.surf.gii" ADAP_BARY_AREA "${dst_dir}/${subject_id}_hemi-${hemi}_${metrics}.10k.shape.gii" -area-surfs "${src_dir}/${subject_id}_hemi-${hemi}_midthickness.surf.gii" "${dst_dir}/${subject_id}_hemi-${hemi}_midthickness.10k.surf.gii"
        done
    done


    for hemi in left right; do

        # regress out the effect of cortical curvature on thickness
        wb_command -metric-regression "${dst_dir}/${subject_id}_hemi-${hemi}_thickness.10k.shape.gii" "${dst_dir}/${subject_id}_hemi-${hemi}_thickness_corr.10k.shape.gii" -remove "${dst_dir}/${subject_id}_hemi-${hemi}_curv.10k.shape.gii"
    done


    for hemi in left right; do
        for anat in pial wm midthickness; do

            # regress out the effect of cortical curvature on SA
            wb_command -metric-regression "${dst_dir}/${subject_id}_hemi-${hemi}_${anat}_va.10k.shape.gii" "${dst_dir}/${subject_id}_hemi-${hemi}_${anat}_va_corr.10k.shape.gii" -remove "${dst_dir}/${subject_id}_hemi-${hemi}_curv.10k.shape.gii"
        done
    done


    echo "Processing of ${subject_id} completed."

done < <(sed -n "${SLURM_ARRAY_TASK_ID}p" $subject_list)