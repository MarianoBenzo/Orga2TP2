#!/usr/bin/env python

from libtest import *
import subprocess
import sys

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.


IMAGENES=["lena.bmp"]

assure_dirs()

sizes=['192x192', '256x256', '320x320', '384x384', '448x448', '512x512', '640x640', '768x768', '896x896', '1024x1024']


for filename in IMAGENES:
	print(filename)

	for size in sizes:
		sys.stdout.write("  " + size)
		name = filename.split('.')
		file_in  = DATADIR + "/" + filename
		file_out = TESTINDIR + "/" + name[0] + "." + size + "." + name[1]
		resize = "convert -resize " + size + "! " + file_in + " " + file_out
		subprocess.call(resize, shell=True)

print("")
