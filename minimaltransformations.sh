# standard reorientation
ls path/to/t1w*.nii.gz | parallel --plus fslreorient2std {} {..}_stdorient.nii.gz
# antspynet based brain masking
ls path/to/t1w*_stdorient.nii.gz | parallel --plus antspynet_bet.sh {} t1 {..}_mask.nii.gz
# bias field correction
ls path/to/t1w*stdorient.nii.gz | parallel --plus N4BiasFieldCorrection -d 3 -i {} -x {..}_mask.nii.gz -r -o {..}_bfc.nii.gz
# applying the mask
ls path/to/t1w*stdorient.nii.gz | parallel --plus fslmaths {..}_bfc.nii.gz -mas {..}_mask.nii.gz {..}_bfc_masked.nii.gz
# linear registration to MNI
ls path/to/t1w*_bfc_masked.nii.gz | parallel --plus flirt -in {} -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -cost normmi -omat {..}_flirt.mat -out {..}_intemplate.nii.gz
# dilating the MNI brain mask
fslmaths $FSLDIR/data/standard/MNI152_T1_2mm_brain_mask -dilM MNI152_T1_1mm_brain_mask_dil1
# non-linear registration to MNI
ls path/to/t1w*_bfc_masked.nii.gz | parallel --plus fnirt --in={} --ref=$FSLDIR/data/standard/MNI152_T1_2mm --cout={..}_to_MNI_nonlin_coeff --config=$FSLDIR/etc/flirtsch/T1_2_MNI152_2mm.cnf --aff={..}_flirt.mat --refmask=MNI152_T1_2mm_brain_mask_dil1
# applying the linear and non-linear transformation to MNI
ls *bfc.nii.gz | parallel --plus applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in={} --warp={..}_masked_to_MNI_nonlin_coeff --out={..}_to_MNI_nonlin
# make csv with
path/to/*_to_MNI_nonlin.nii.gz,age,sex
# proceed with the TSAN prediction based on the instructions from that package
