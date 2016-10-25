#!/usr/bin/env python

import os
import sys
from os import remove
from os.path import isfile
from libtest import *

#Arma el set de datos para los histogramas de cada filtro declarado en corridas_nuestro
#Output: "filtro_exp.dat" (si ya existia el archivo, lo sobreescribe)
#Correr: python armar_histograma_exp.py ASM Exp
#Ejemplo de nombres de archivos de mediciones: "medicion.pixelar.control.txt", "medicion.pixelar.exp.txt", "medicion.pixelar.ASM.txt"
#Como son graficos de barra, se asume que hay una unica medicion por archivo
for corrida in corridas_nuestro:
	#Armo la estructura del archivo de salida
	if isfile(corrida['filtro'] + ".dat"): 
		remove(corrida['filtro'] + ".dat")
	f = open(corrida['filtro'] + ".dat", "w+")
	f.write("Implementacion\t")
	for implementacion in sys.argv:
		if implementacion != "armar_histograma_exp.py":
			f.write(implementacion + " ")
	f.write("\n")
	f.write("-Varianza\t\n")
	f.write("Promedio\t\n")
	f.write("+Varianza\t\n")
	f.close()
	for implementacion in sys.argv:
		if implementacion != "armar_histograma_exp.py": 			#Ignoro el nombre del script en los argumentos
			importar_porcentajes(corrida['filtro'], implementacion)