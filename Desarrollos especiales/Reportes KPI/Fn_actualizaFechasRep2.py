servidor = '10.0.10.10\CLOUDQA'
usuario  = 'userrepkpi'
base     = 'ncti'
password = 'triplei'

# Función que realiza la Actualización de la entidad repParametrosFechaTbl que se encuentra en la base de datos NCTI.
# Mediante la ejecución del Script "instruccion3.txt".

def Fn_actualizaFechaRep2():
    global area
    global servidor
    global base
    global usuario
    global password

#
# Obtiene la inctrucción a ejecutar
#

with open("instruccion3.txt") as file_object:
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
# Ejecuta Instrucción en la base de datos NCTI obtenida del script instruccion3.txt
#
                
                cursor.execute(SQL_QUERY)

except Exception as ex:
   print("Error en Conexion a la BD: {}".format(ex))

finally:

      conexion.close()

Fn_actualizaFechaRep2()
