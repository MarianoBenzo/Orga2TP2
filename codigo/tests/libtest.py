import os
import subprocess
from os import listdir
from os.path import isfile, join
from termcolor import colored

DATADIR = "./data"
TESTINDIR = DATADIR + "/imagenes_a_testear"
CATEDRADIR = DATADIR + "/resultados_catedra"
ALUMNOSDIR = DATADIR + "/resultados_nuestros"
TP2ALU = "../build/tp2"
TP2CAT = "./tp2catedra"
DIFF = "../build/bmpdiff"
DIFFFLAGS = ""

corridas = [
    {'filtro': 'colorizar', 'tolerancia': 10, 'params': '0.5'},
    {'filtro': 'combinar', 'tolerancia': 5, 'params': '128.0'},
    {'filtro': 'pixelar', 'tolerancia': 5, 'params': ''},
    {'filtro': 'rotar', 'tolerancia': 0, 'params': ''},
    {'filtro': 'smalltiles', 'tolerancia': 0, 'params': ''}
]

corridas_nuestro = [
    {'filtro': 'colorizar', 'params': '0.5'},
    #{'filtro': 'combinar', 'params': '128.0'},
    #{'filtro': 'pixelar', 'params': ''},
    #{'filtro': 'rotar', 'params': ''},
    #{'filtro': 'smalltiles', 'params': ''}
]

def make_dir(name):
    if not os.path.exists(name):
        os.mkdir(name)


def assure_dirs():
    make_dir(TESTINDIR)
    make_dir(CATEDRADIR)
    make_dir(ALUMNOSDIR)

def importar_porcentajes(filtro, implementacion):
    origen = "medicion." + filtro + "." + implementacion + ".txt"
    control = "medicion." + filtro + ".control.txt"
    salida = filtro + "_exp.dat"    
    c = open(control, "r")
    f = open(origen, "r")
    o = open(salida, "a+")

    medicion = f.read()
    lineas = medicion.splitlines()
    promedio = lineas[2]
    varianza = lineas[3]
    promedio = float(promedio.lstrip("Promedio: "))
    varianza = float(varianza.lstrip("Desviacion estandar: "))
    menosVarianza = promedio - varianza
    masVarianza = promedio + varianza

    medicionC = c.read()
    lineasC = medicionC.splitlines()
    promedioC = lineasC[2]
    varianzaC = lineasC[3]
    promedioC = float(promedioC.lstrip("Promedio: "))
    varianzaC = float(varianzaC.lstrip("Desviacion estandar: "))
    menosVarianzaC = promedioC - varianzaC
    masVarianzaC = promedioC + varianzaC

    pctMasVarianza = (masVarianza * 100) / masVarianzaC
    pctPromedio = (promedio * 100) / promedioC
    pctMenosVarianza = (menosVarianza * 100) / menosVarianzaC

    pctMejoraMasV = 100 - pctMasVarianza
    pctMejoraP = 100 - pctPromedio
    pctMejoraMenosV = 100 - pctMenosVarianza

    o.write(implementacion + "\t" + str(pctMejoraMenosV) + " " + str(pctMejoraP) + " " + str(pctMejoraMasV) + "\n")
    # output = o.read()
    # o_lines = output.splitlines()

    # lineaMasVarianza = o_lines[1]
    # lineaPromedio = o_lines[2]
    # lineaMenosVarianza = o_lines[3]

    # lineaMasVarianza = lineaMasVarianza.strip("\n") + str(pctMejoraMV) + " \n"
    # lineaPromedio = lineaPromedio.strip("\n") + str(pctVarianza) + " \n"
    # lineaMenosVarianza = lineaMenosVarianza.strip("\n") + str(pctVarianza) + " \n"

    # o.seek(0)
    # o.write(o_lines[0] + "\n" + lineaMasVarianza + lineaPromedio + lineaMenosVarianza)  
    c.close()
    f.close()
    o.close()

def importar_datos(filtro, implementacion):
    if (implementacion != "00" and implementacion[0] == "0"):
        implementacion = "C_" + implementacion
    if implementacion == "00":
        implementacion = "C"
    origen = "medicion." + filtro + "." + implementacion + ".txt"
    salida = filtro + ".dat"
    f = open(origen, "r")
    o = open(salida, "r+")

    medicion = f.read()
    lineas = medicion.splitlines()
    promedio = lineas[2]
    varianza = lineas[3]
    promedio = promedio.lstrip("Promedio: ")
    varianza = varianza.lstrip("Desviacion estandar: ")

    menosVarianza = float(promedio) - float(varianza)

    output = o.read()
    o_lines = output.splitlines()
    
    lineaMenosVarianza = o_lines[1]
    lineaPromedio = o_lines[2]
    lineaMasVarianza = o_lines[3]

    lineaMenosVarianza = lineaMenosVarianza.strip("\n") + str(menosVarianza) + " \n"
    lineaPromedio = lineaPromedio.strip("\n") + varianza + " \n"
    lineaMasVarianza = lineaMasVarianza.strip("\n") + varianza + " \n"

    o.seek(0)
    o.write(o_lines[0] + "\n" + lineaMenosVarianza + lineaPromedio + lineaMasVarianza)

    f.close()
    o.close()


def archivos_tests():
    return [f for f in sorted(listdir(TESTINDIR)) if isfile(join(TESTINDIR, f))]


def correr_filtro(filtro, implementacion, archivo_in, extra_params, corridas):
    comando = TP2ALU + " " + filtro
    argumentos = " -i " + implementacion + " -t " + corridas + " -o " + ALUMNOSDIR + "/ " + TESTINDIR + "/" + archivo_in + ' ' + extra_params
    subprocess.call(comando + argumentos, shell=True)


def correr_catedra(filtro, implementacion, archivo_in, extra_params):
    comando = TP2CAT + " " + filtro
    argumentos = " -i " + implementacion + " -o " + CATEDRADIR + "/ " + TESTINDIR + "/" + archivo_in + ' ' + extra_params
    subprocess.call(comando + argumentos, shell=True)
    archivo_out = subprocess.check_output(comando + ' -n ' + argumentos, shell=True)
    return archivo_out.decode('utf-8').strip()


def correr_alumno(filtro, implementacion, archivo_in, extra_params):
    comando = TP2ALU + " " + filtro
    argumentos = " -i " + implementacion + " -o " + ALUMNOSDIR + "/ " + TESTINDIR + "/" + archivo_in + ' ' + extra_params
    subprocess.call(comando + argumentos, shell=True)
    archivo_out = subprocess.check_output(comando + ' -n ' + argumentos, shell=True)
    return archivo_out.decode('utf-8').strip()


def hay_diferencias(out_cat, out_alu, tolerancia):
    comando = DIFF + " " + DIFFFLAGS + " " + CATEDRADIR + "/" + out_cat + " " + ALUMNOSDIR + "/" + out_alu + " " + str(
        tolerancia)
    print(comando)
    return subprocess.call(comando, shell=True)


def verificar(filtro, extra_params, tolerancia, implementacion, archivo_in):
    mensaje = "filtro " + filtro + " version catedra contra tu " + implementacion
    print(colored(mensaje, 'blue'))

    archivo_out_cat = correr_catedra(filtro, 'c', archivo_in, extra_params)
    archivo_out_alu = correr_alumno(filtro, implementacion, archivo_in, extra_params)

    if hay_diferencias(archivo_out_cat, archivo_out_alu, tolerancia):
        print(colored("error en " + archivo_out_alu, 'red'))
        return False
    else:
        print(colored("iguales!", 'green'))
        return True
