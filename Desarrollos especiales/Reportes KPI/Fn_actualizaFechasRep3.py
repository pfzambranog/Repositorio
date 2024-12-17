servidor = '10.0.10.10\CLOUDQA'
usuario  = 'userrepkpi'
base     = 'ncti'
password = 'triplei'

# Función que realiza la solicitud de notificación (Motivo 1019) para informar que los datos del reporte KPI ya estan actualizados.
# mendiante la ejecución del script ComandoRep3.txt

def Fn_actualizaFechaRep3():
    global area
    global servidor
    global base
    global usuario
    global password

#
# Obtiene la inctrucción a ejecutar
#

with open("ComandoRep3.txt") as file_object:
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
# Ejecuta Instrucción en la base de datos NCTI obtenida del script ComandoRep3.txt
#

                cursor.execute(SQL_QUERY)

except Exception as ex:
   print("Error en Conexion a la BD: {}".format(ex))

finally:

      conexion.close()

Fn_actualizaFechaRep3()
