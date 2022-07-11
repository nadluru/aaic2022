#!/usr/bin/env python

# Importing the necessary libraries
import ants
import antspynet
import click

@click.command()
@click.argument("img", nargs = 1, type = click.Path(exists = True))
@click.argument("mod", nargs = 1)
@click.argument("mask", nargs = 1)
def ANTSPYNET_BET(img, mod, mask):
    antspynet.utilities.brain_extraction(ants.image_read(img), modality = mod, antsxnet_cache_directory = "/local/corebuild").to_file(mask)
    #antspynet.utilities.brain_extraction(ants.image_read("/local/corebuild/ecpt1wtransformations/EC2131_t1w_iso_reorient.nii.gz"), modality="t1", antsxnet_cache_directory = "/local/corebuild").to_file("/local/corebuild/tmp.nii.gz")

if __name__ == "__main__":
    ANTSPYNET_BET()