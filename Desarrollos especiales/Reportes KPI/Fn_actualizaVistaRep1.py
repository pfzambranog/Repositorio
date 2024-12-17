servidor = '192.168.14.32'
puerto = '3306'
usuario = 'interfase'
base = 'sgccti'
password = 'triplei.mx'

def Fn_actualizaVistaRep1():
    global servidor
    global puerto
    global usuario
    global password
    global base

# Función que actualiza la vista spp_movcontrolcambiosVw() en la base de datos SGCCTI
# Ejecutando la instrucción contenida en el script ComandoActRep.txt

from mysql.connector import Error
import mysql.connector

#
# Obtiene la inctrucción a ejecutar
#

with open("ComandoActRep.txt") as file_object:
        SQL_QUERY = file_object.read()

try:

   connectionMdb = mysql.connector.connect(host   = servidor,
                                           port   = puerto,
                                           user   = usuario,
                                           passwd = password,
                                           db     = base)
   
   
   if connectionMdb.is_connected():
#
# Establece conexión a la BD sgccti en el servidor 192.168.14.32
#
            
      proceso = connectionMdb.cursor()

#
# Ejecuta Instrucción en la base de datos sgccti obtenida del script ComandoActRep.txt
#
      
      proceso.execute(SQL_QUERY)

    
except Error as ex:
   print("Error en Conexion a la BD: {}".format(ex))


finally:
   if connectionMdb.is_connected():
      connectionMdb.close()

Fn_actualizaVistaRep1()

