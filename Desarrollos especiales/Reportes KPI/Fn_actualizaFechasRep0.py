servidor = '192.168.14.32'
usuario  = 'interfase'
password = 'triplei.mx'
base     = 'sgccti'

# Función que actualiza los Parametros de fecha para el
# Reporte de Movimientos de control de cambio en la base de datos sgccti.

def Fn_actualizaFechaRep0():
    global area
    global w_con
    global servidor
    global usuario 
    global password
    global base

#
# Obtiene la inctrucción a ejecuctar
#

with open("ComandoRep2.txt") as file_object:
        SQL_QUERY = file_object.read()

import pyodbc

w_con = 'DRIVER={MySQL ODBC 8.2 ANSI Driver};SERVER = ' + servidor + ';DATABASE = ' + base + ';UID = ' + usuario + ';PWD = ' + password

try:
#
# Establece conexión a la BD sgccti en el servidor 192.168.14.32
#

    conexion = pyodbc.connect(w_con)
#
# Ejecuta Instrucción en la base de datos sgccti obtenida de archiivo ComandoRep2.txt
#
    
    conexion.execute(SQL_QUERY)   
 
except Exception as ex:
   print("Error en Conexion a la BD: {}".format(ex))

finally:

      conexion.close()

Fn_actualizaFechaRep0()
