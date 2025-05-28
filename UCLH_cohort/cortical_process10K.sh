#!/bin/bash

#SBATCH --partition=cpu
#SBATCH --time=0-1:00
#SBATCH --nodes=1
#SBATCH --mem=2048
#SBATCH --ntasks=4 
#SBATCH --job-name=MSMsulc
#SBATCH --array=1-213


# Define the base directory and destination paths
ciftify_dir="/scratch_tmp/prj/cortical_imaging/kaili_tmp/UCCHILD/UCCHILD_ciftify6"
des_dir="/scratch_tmp/prj/cortical_imaging/kaili_tmp/UCCHILD/MSMsulc"
subject_list="/scratch_tmp/prj/cortical_imaging/kaili_tmp/UCCHILD/subject_list213.txt"


# Config file and template paths (assuming these are constant for all subjects)
sphere_temp="/scratch_tmp/prj/cortical_imaging/kaili_tmp/templates_conf"


# Read each subject ID from the file
while IFS= read -r subject_id; do
    echo "Processing ${subject_id}..."

    # Define subject-specific paths
    src_dir_t1w="${ciftify_dir}/${subject_id}/T1w/Native"
    src_dir="${ciftify_dir}/${subject_id}/MNINonLinear/Native"
    dst_dir="${des_dir}/${subject_id}/10K_ico5"

    # Create destination directory if it doesn't exist
    mkdir -p "${dst_dir}"

    
    for hemi in L R; do
        for anat in pial white midthickness; do

            # resample surface from T1w/Native
            wb_command -surface-resample "${src_dir_t1w}/${subject_id}.${hemi}.${anat}.native.surf.gii" "${des_dir}/${subject_id}/${hemi}rot.sphere.reg.surf.gii" "${sphere_temp}/ico-5_${hemi}.surf.gii" BARYCENTRIC "${dst_dir}/${subject_id}.${hemi}.${anat}.10k_t1native.surf.gii"

            # resample surface
            wb_command -surface-resample "${src_dir}/${subject_id}.${hemi}.${anat}.native.surf.gii" "${des_dir}/${subject_id}/${hemi}rot.sphere.reg.surf.gii" "${sphere_temp}/ico-5_${hemi}.surf.gii" BARYCENTRIC "${dst_dir}/${subject_id}.${hemi}.${anat}.10k.surf.gii"

        done
    done


    for hemi in L R; do
        for anat in pial white midthickness; do

            # calculate vertex areas from 10k surface
            wb_command -surface-vertex-areas "${dst_dir}/${subject_id}.${hemi}.${anat}.10k_t1native.surf.gii" "${dst_dir}/${subject_id}.${hemi}.${anat}_va.10k.shape.gii"

        done
    done




    for hemi in L R; do
        for metrics in sulc curvature thickness; do

            # resample metrics
            wb_command -metric-resample "${des_dir}/${subject_id}/${subject_id}.${hemi}.${metrics}.native.shape.gii" "${des_dir}/${subject_id}/${hemi}rot.sphere.reg.surf.gii" "${sphere_temp}/ico-5_${hemi}.surf.gii" ADAP_BARY_AREA "${dst_dir}/${subject_id}.${hemi}.${metrics}.10k.shape.gii" -area-surfs "${src_dir}/${subject_id}.${hemi}.midthickness.native.surf.gii" "${dst_dir}/${subject_id}.${hemi}.midthickness.10k.surf.gii"
        done
    done


    for hemi in L R; do

        # regress out the effect of cortical curvature on thickness
        wb_command -metric-regression "${dst_dir}/${subject_id}.${hemi}.thickness.10k.shape.gii" "${dst_dir}/${subject_id}.${hemi}.thickness_corr.10k.shape.gii" -remove "${dst_dir}/${subject_id}.${hemi}.curvature.10k.shape.gii"
    done


    for hemi in L R; do
        for anat in pial white midthickness; do

            # regress out the effect of cortical curvature on SA
            wb_command -metric-regression "${dst_dir}/${subject_id}.${hemi}.${anat}_va.10k.shape.gii" "${dst_dir}/${subject_id}.${hemi}.${anat}_corr_va.10k.shape.gii" -remove "${dst_dir}/${subject_id}.${hemi}.curvature.10k.shape.gii"

        done
    done



    for hemi in L R; do

        wb_command -label-resample "${des_dir}/${subject_id}/${subject_id}.${hemi}.DKatlas.native.label.gii" "${des_dir}/${subject_id}/${hemi}rot.sphere.reg.surf.gii" "${sphere_temp}/ico-5_${hemi}.surf.gii" ADAP_BARY_AREA "${dst_dir}/${subject_id}.${hemi}.DKatlas.10k.label.gii" -area-surfs "${src_dir}/${subject_id}.${hemi}.midthickness.native.surf.gii" "${dst_dir}/${subject_id}.${hemi}.midthickness.10k.surf.gii"
    done

    for hemi in L R; do

        wb_command -surface-generate-inflated "${dst_dir}/${subject_id}.${hemi}.midthickness.10k.surf.gii" "${dst_dir}/${subject_id}.${hemi}.inflated.10k.surf.gii" "${dst_dir}/${subject_id}.${hemi}.very_inflated.10k.surf.gii" -iterations-scale 0.75
    done

            

    echo "Processing of ${subject_id} completed."

done < <(sed -n "${SLURM_ARRAY_TASK_ID}p" $subject_list)