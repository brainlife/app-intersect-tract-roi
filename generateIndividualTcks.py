#!/usr/bin/env python3

import os, sys 
import json
import numpy as np, nibabel as nib, scipy.io as sio
from dipy.io.streamline import load_tractogram, save_tck
from dipy.io.stateful_tractogram import Space, StatefulTractogram

def generateIndividualTcks():
   
   # set paths
   with open('config.json','r') as config_f:
      config = json.load(config_f)

   # load data
   print("loading data")
   ref = nib.load(config['reference_anatomy'])
   wholebrain = load_tractogram(config['track_path'],ref) 
   classification = sio.loadmat(config['classification_path'],squeeze_me=True)
   print("loading data complete")

   # obtain tract index
   print("extracting bundles of interest")   
   # class_indices = list(classification['classification'][0]['index'][0])
   class_indices = list(classification['classification'].item()[1])
   # class_names = classification['classification'][0]['names'][0][0]
   class_names = classification['classification'].item()[0]

   for i in np.unique(class_indices):
      tract_name = class_names[i-1]
      tract_indices = [ f for f in range(len(class_indices)) if class_indices[f] == i ]
      print(tract_name)
      # select tract and save tck
      fg = wholebrain.streamlines[tract_indices]
      sft = StatefulTractogram(fg,ref,Space.RASMM)
      save_tck(sft,'track_'+str(i)+'.tck')

if __name__ == '__main__':
	generateIndividualTcks()


