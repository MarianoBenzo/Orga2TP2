#!/usr/bin/env python

import os
import sys
from os import remove
from os.path import isfile
from libtest import *

#Arma el set de datos para los histogramas de cada filtro declarado en corridas_nuestro
#Output: "filtro.dat" (si ya existia el archivo, lo sobreescribe)
#Correr: python armar_histograma.py args
#args: ASM, 00, 01, 02, 03 (pueden ir en cualquier orden y cualquier cantidad, mientras no sea vacia)
#Ejemplo de nombres de archivos de mediciones: "medicion.pixelar.C_03.txt", "medicion.pixelar.ASM.txt", "medicion.pixelar.C.txt"
#Como son graficos de barra, se asume que hay una unica medicion por archivo
for corrida in corridas_nuestro:
	#Armo la estructura del archivo de salida
	if isfile(corrida['filtro'] + ".dat"): 
		remove(corrida['filtro'] + ".dat")
	f = open(corrida['filtro'] + ".dat", "w+")
	f.write("Datos\t")
	f.write("-Varianza\t")
	f.write("Promedio\t")
	f.write("+Varianza\t")
	f.write("\n")
	f.close()
	for implementacion in sys.argv:
		if implementacion != "armar_histograma.py": 			#Ignoro el nombre del script en los argumentos
			importar_datos(corrida['filtro'], implementacion)