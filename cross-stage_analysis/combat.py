import pandas as pd
import nibabel as nib
import numpy as np
from neuroCombat import neuroCombat

# File paths
gifti_files = [
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.left.sulc.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.left.thickness_corr.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.left.whiteSA_corr.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.right.sulc.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.right.thickness_corr.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.right.whiteSA_corr.10k.shape.gii"
]

output_files = [
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.left.sulc_removesites.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.left.thickness_corr_removesites.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.left.whiteSA_corr_removesites.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.right.sulc_removesites.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.right.thickness_corr_removesites.10k.shape.gii",
    "/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/BIPP_UCCHILD_dHCP.right.whiteSA_corr_removesites.10k.shape.gii"
]

# Load demo data
demo_file = "/data/BVPT_ALLanalysis/palm_analysis_final1074/BIPP_UCCHILD_dHCPalldemo1074.xlsx"
data = pd.read_excel(demo_file)

# Extract covariates
covars = data[['group_VPT1', 'sex_0female_1male', 'volume', 'age_weeks', 'sites']]
categorical_cols = ['sex_0female_1male', 'group_VPT1']
batch_col = 'sites'

# Load GIFTI data and aggregate
vertex_values = []

for file_path in gifti_files:
    gifti_img = nib.load(file_path)
    # Read all darrays and combine as a matrix where rows are subjects and columns are vertices
    file_data = np.array([darray.data for darray in gifti_img.darrays])  # Shape: (subjects, vertices)
    vertex_values.append(file_data)

# Concatenate data from all files along columns
dat = np.hstack(vertex_values).T
print(f"Aggregated data shape: {dat.shape}")  # Expected shape: (vertices * number_of_files, subjects)

# Perform batch effect correction
adjusted_data = neuroCombat(
    dat=dat,
    covars=covars,
    batch_col=batch_col,
    categorical_cols=categorical_cols,
    eb=True
)['data']

# Transpose adjusted data back for saving
adjusted_data = adjusted_data.T.astype(np.float32)  # Explicitly cast to float32
print(adjusted_data.dtype, adjusted_data.shape)


# Split the adjusted data back into file-specific matrices
start_col = 0
for i, file_path in enumerate(gifti_files):
    gifti_img = nib.load(file_path)
    num_vertices = gifti_img.darrays[0].data.shape[0]

    # Extract the adjusted data for the current file
    adjusted_file_data = adjusted_data[:, start_col:start_col + num_vertices]
    start_col += num_vertices

    # Create new GiftiImage
    new_gifti_img = nib.gifti.GiftiImage()

    # Add adjusted data as new GiftiDataArray
    for subject_data in adjusted_file_data:
        new_data_array = nib.gifti.GiftiDataArray(subject_data, encoding='GZipBase64Binary', intent='NIFTI_INTENT_SHAPE')
        new_gifti_img.add_gifti_data_array(new_data_array)

    # Preserve metadata if needed
    new_gifti_img.meta = gifti_img.meta

    # Save the adjusted GIFTI file
    nib.save(new_gifti_img, output_files[i])

print("Batch effect correction completed. Adjusted data saved.")
