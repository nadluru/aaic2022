#!/bin/bash
img=$1
modality=$2
mask=$3

$HOME/UtilitiesProject/antspynet_bet.py $img $modality $mask
mrcalc $mask 0.05 -ge 1 0 -if ${mask%.nii.gz}_thr.nii.gz -force
connectedcomp ${mask%.nii.gz}_thr ${mask%.nii.gz}_cc 26
mrcalc ${mask%.nii.gz}_cc.nii.gz $(LabelGeometryMeasures 3 ${mask%.nii.gz}_cc.nii.gz | awk -F " " '{print $1,$2}' | sed 1d | sort -k2 -g -r | head -n1 | awk '{print $1}') -eq 1 0 -if ${mask} -force
rm -f ${mask%.nii.gz}_thr.nii.gz ${mask%.nii.gz}_cc.nii.gz
