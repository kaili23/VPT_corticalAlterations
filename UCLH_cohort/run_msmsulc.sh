#!/bin/bash

#SBATCH --partition=cpu
#SBATCH --time=0-2:00
#SBATCH --nodes=1
#SBATCH --mem=2048
#SBATCH --ntasks=4 
#SBATCH --job-name=MSMsulc
#SBATCH --array=1-218

# Define the base directory for the source and destination paths
base_src_dir="/scratch/prj/cap_bipp/kaili/UCCHILD"
base_dst_dir="/scratch/prj/cap_bipp/kaili/UCCHILD/MSMsulc"
subject_list="${base_src_dir}/subject_list218.txt"

# Config file and template paths
conf_file="${base_src_dir}/config_subject_to_40_week_template_3rd_release"
left_ref_mesh="${base_src_dir}/HCPtemplates/fsaverage.L_LR.spherical_std.164k_fs_LR.surf.gii"
right_ref_mesh="${base_src_dir}/HCPtemplates/fsaverage.R_LR.spherical_std.164k_fs_LR.surf.gii"
left_ref_data="${base_src_dir}/HCPtemplates/L.refsulc.164k_fs_LR.shape.gii"
right_ref_data="${base_src_dir}/HCPtemplates/R.refsulc.164k_fs_LR.shape.gii"

# Read the subject ID from the file based on SLURM_ARRAY_TASK_ID
while IFS= read -r subject_id; do
    echo "Processing ${subject_id}..."

    # Define subject-specific paths
    src_dir="${base_src_dir}/UCCHILD_ciftify6/${subject_id}/MNINonLinear/Native"
    dst_dir="${base_dst_dir}/${subject_id}"

    # Create destination directory if it doesn't exist
    mkdir -p "${dst_dir}"

    # Copy the necessary files
    cp "${src_dir}/${subject_id}.sulc.native.dscalar.nii" "${dst_dir}"
    cp "${src_dir}/${subject_id}.L.sphere.rot.native.surf.gii" "${dst_dir}"
    cp "${src_dir}/${subject_id}.R.sphere.rot.native.surf.gii" "${dst_dir}"

    # Run wb_command
    wb_command -cifti-separate "${dst_dir}/${subject_id}.sulc.native.dscalar.nii" COLUMN -metric CORTEX_LEFT "${dst_dir}/${subject_id}.L.sulc.native.shape.gii" -metric CORTEX_RIGHT "${dst_dir}/${subject_id}.R.sulc.native.shape.gii"

    # Run newmsm for left hemisphere
    newmsm --conf="${conf_file}" --inmesh="${dst_dir}/${subject_id}.L.sphere.rot.native.surf.gii" --refmesh="${left_ref_mesh}" --indata="${dst_dir}/${subject_id}.L.sulc.native.shape.gii" --refdata="${left_ref_data}" --out="${dst_dir}/Lrot."

    # Run newmsm for right hemisphere
    newmsm --conf="${conf_file}" --inmesh="${dst_dir}/${subject_id}.R.sphere.rot.native.surf.gii" --refmesh="${right_ref_mesh}" --indata="${dst_dir}/${subject_id}.R.sulc.native.shape.gii" --refdata="${right_ref_data}" --out="${dst_dir}/Rrot."

    echo "Processing of ${subject_id} completed."

done < <(sed -n "${SLURM_ARRAY_TASK_ID}p" $subject_list)
