servidor = '192.168.14.32'
usuario  = 'interfase'
password = 'triplei.mx'
base     = 'sgccti'

# Función que Genera el archivo "instruccion3.txt", consultando a la tabla repParametrosFechaTbl que se encuentra en
# la base de datos sgccti, mediante la ejecución del comando contenido en el script "ComandoRep.txt"


def Fn_actualizaFechaRep1():
    global area
    global w_con
    global servidor
    global usuario 
    global password
    global base
#
# Obtiene la inctrucción a ejecutar
#
   
with open("ComandoRep.txt") as file_object:
        SQL_QUERY = file_object.read()

import pyodbc

w_con = 'DRIVER={MySQL ODBC 8.2 ANSI Driver};SERVER = ' + servidor + ';DATABASE = ' + base + ';UID = ' + usuario + ';PWD = ' + password

try:
    conexion = pyodbc.connect(w_con)

#
# Establece conexión a la BD sgccti en el servidor 192.168.14.32
#
    with open('instruccion3.txt', 'a') as f:
            with conexion.cursor() as cursor:
#
# Ejecuta Instrucción en la base de datos sgccti obtenida de archiivo ComandoRep.txt
#
                cursor.execute(SQL_QUERY)
#
# Genera el script instruccion3.txt
#
                resulset = cursor.fetchall()
                for row in resulset:
                     for line in row:
                          f.write(line + '\n')
 

except Exception as ex:
   print("Error en Conexion a la BD: {}".format(ex))

finally:

      conexion.close()

Fn_actualizaFechaRep1()
