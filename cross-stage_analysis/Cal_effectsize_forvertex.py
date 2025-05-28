import pandas as pd
import nibabel as nib
import numpy as np

# File paths for GIFTI files
control_files = [
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_control.left.sulc.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_control.left.thickness.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_control.left.whiteSA.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_control.right.sulc.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_control.right.thickness.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_control.right.whiteSA.10k.shape.gii"
]

vpt_files = [
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_VPT.left.sulc.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_VPT.left.thickness.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_VPT.left.whiteSA.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_VPT.right.sulc.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_VPT.right.thickness.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_VPT.right.whiteSA.10k.shape.gii"
]

mask_files = {
    "left_sulc": "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/group_comp/L_Term_Preterm_tfce_tstat_mcfwep_m1_mask.shape.gii",
    "left_thickness": "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/group_comp/L_Term_Preterm_tfce_tstat_mcfwep_m2_mask.shape.gii",
    "left_SA": "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/group_comp/L_Term_Preterm_tfce_tstat_mcfwep_m3_mask.shape.gii",
    "right_sulc": "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/group_comp/R_Term_Preterm_tfce_tstat_mcfwep_m1_mask.shape.gii",
    "right_thickness": "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/group_comp/R_Term_Preterm_tfce_tstat_mcfwep_m2_mask.shape.gii",
    "right_SA": "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/group_comp/R_Term_Preterm_tfce_tstat_mcfwep_m3_mask.shape.gii"
}

# Function to calculate effect size for all vertices, setting missing values to 0 for unmasked vertices
def calculate_effect_size(control_file, vpt_file, mask_file):
    # Load GIFTI data and mask
    control_img = nib.load(control_file)
    vpt_img = nib.load(vpt_file)
    mask_img = nib.load(mask_file)

    # Extract data arrays
    control_data = np.array([darray.data for darray in control_img.darrays])
    vpt_data = np.array([darray.data for darray in vpt_img.darrays])
    mask = mask_img.darrays[0].data

    # Initialize effect size array for all vertices
    effect_size = np.zeros_like(mask, dtype=np.float32)

    # Apply mask (mask == 1)
    mask_indices = np.where(mask == 1)[0]
    control_masked = control_data[:, mask_indices]
    vpt_masked = vpt_data[:, mask_indices]

    # Calculate mean and std for effect size
    control_mean = np.mean(control_masked, axis=0)
    vpt_mean = np.mean(vpt_masked, axis=0)
    control_std = np.std(control_masked, axis=0, ddof=1)
    vpt_std = np.std(vpt_masked, axis=0, ddof=1)

    # Calculate pooled standard deviation
    n1, n2 = control_masked.shape[0], vpt_masked.shape[0]
    pooled_std = np.sqrt(((n1 - 1) * control_std**2 + (n2 - 1) * vpt_std**2) / (n1 + n2 - 2))

    # Calculate Cohen's d
    effect_size_masked = (vpt_mean - control_mean) / pooled_std

    # Assign calculated effect size to masked vertices
    effect_size[mask_indices] = effect_size_masked

    return effect_size

# Process each file pair and calculate effect size
for i, (control_file, vpt_file) in enumerate(zip(control_files, vpt_files)):
    # Determine the mask type
    file_type = list(mask_files.keys())[i % len(mask_files)]
    mask_file = mask_files[file_type]

    # Calculate effect size
    effect_size = calculate_effect_size(control_file, vpt_file, mask_file)

    # Save effect size as GIFTI file
    effect_size_data = nib.gifti.GiftiDataArray(effect_size, encoding='GZipBase64Binary', intent='NIFTI_INTENT_SHAPE')
    effect_size_img = nib.gifti.GiftiImage(darrays=[effect_size_data])
    output_file = f"/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_sitesAScovariates/dHCP_EffectSize.{file_type}.10k.shape.gii"
    nib.save(effect_size_img, output_file)
    print(f"Effect size for {file_type} saved to {output_file}")

print("Effect size calculation completed.")
