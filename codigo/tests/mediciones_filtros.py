#!/usr/bin/env python

import os
from os import remove
from os.path import isfile
from termcolor import colored
from libtest import *

print(colored('Ejecutando filtros', 'blue'))

archivos = archivos_tests()
for corrida in corridas_nuestro:
	print(colored('Corriendo ' + corrida['filtro'], 'green'))
	if isfile('medicion.' + corrida['filtro'] + '.C.txt'):
		remove('medicion.' + corrida['filtro'] + '.C.txt')
	if isfile('medicion.' + corrida['filtro'] + '.ASM.txt'):
		remove('medicion.' + corrida['filtro'] + '.ASM.txt')
    	for imagen in archivos:
        	correr_filtro(corrida['filtro'], 'asm', imagen, corrida['params'], '100')
        	correr_filtro(corrida['filtro'], 'c', imagen, corrida['params'], '100')