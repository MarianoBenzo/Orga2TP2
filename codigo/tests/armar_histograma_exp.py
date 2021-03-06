#!/usr/bin/env python

import os
import sys
from os import remove
from os.path import isfile
from libtest import *

#Arma el set de datos para los histogramas de cada filtro declarado en corridas_nuestro
#Output: "filtro_exp.dat" (si ya existia el archivo, lo sobreescribe)
#Correr: python armar_histograma_exp.py ASM exp
#Ejemplo de nombres de archivos de mediciones: "medicion.pixelar.control.txt", "medicion.pixelar.exp.txt", "medicion.pixelar.ASM.txt"
#Como son graficos de barra, se asume que hay una unica medicion por archivo
for corrida in corridas_nuestro:
	#Armo la estructura del archivo de salida
	if isfile(corrida['filtro'] + "_exp.dat"): 
		remove(corrida['filtro'] + "_exp.dat")
	f = open(corrida['filtro'] + "_exp.dat", "w+")
	f.write("Dato\t")
	f.write("-Varianza\t")
	f.write("Promedio\t")
	f.write("+Varianza")
	f.write("\n")
	f.close()
	for implementacion in sys.argv:
		if implementacion != "armar_histograma_exp.py": 			#Ignoro el nombre del script en los argumentos
			importar_porcentajes(corrida['filtro'], implementacion)