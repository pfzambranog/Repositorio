servidor = '10.0.10.10\CLOUDQA'
usuario  = 'userrepkpi'
base     = 'ncti'
password = 'triplei'

# FUnción que realiza la solicitud de notificacion (Motivo 1018) para informar  la fecha tope de la disponibilidad de información del mes
# del reporte KPI de programadores.

def Fn_actualizaFechaRep4():
    global area
    global servidor
    global base
    global usuario
    global password

#
# Obtiene la inctrucción a ejecutar
#

with open("ComandoRep4.txt") as file_object:
        SQL_QUERY = file_object.read()

import pyodbc

w_con = 'DRIVER={SQL Server};SERVER=' + servidor + ';DATABASE=' + base + ';UID=' + usuario + ';PWD='  + password

try:
        conexion = pyodbc.connect  (w_con)

#
# Establece conexión a la BD NCTI en el servidor 10.0.10.10\CLOUDQA
#
        with conexion.cursor() as cursor:
#
# Ejecuta Instrucción en la base de datos NCTI obtenida del script ComandoRep4.txt
#
                cursor.execute(SQL_QUERY)

except Exception as ex:
   print("Error en Conexion a la BD: {}".format(ex))

finally:

      conexion.close()

Fn_actualizaFechaRep4()
