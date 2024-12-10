@echo off

set serv=localhost
set db=DB_Siccorp_DES
Set dir=C:\BaseDatos\DB_Siccorp_DES\
Set dir1=%CD%
set dbTemp=tempdb

cls
@echo on

Echo 
Echo Inicio del Proceso de Generación de la Base de Datos y migración de objetos y datos.
Echo
Echo Press CTRL-C to cancel u otra tecla para continuar
Echo

Pause

Echo "Inicio de Proceso"

rem Recuperación BD ServicioPostal.

If Exist ServicioPostal.bak del ServicioPostal.bak

call "C:\Program Files\WinRAR\unrar.exe" e ServicioPostal.rar


rem Generacion de Base de datos y Tablas.

Call ".\1.- Tablas\mgrTablas.bat" %serv% %db% %dbTemp% %dir% %dir1% 



rem Generación de Disparadores.

Call ".\2.- Triggers\mgrTriggers.bat" %serv% %db% 

rem Generacíón de Funciones

Call ".\3.- Funciones\mgrFunciones.bat"   %serv% %db% 

rem Generacíón de Procedimientos

Call ".\4.- Procedimientos Grales\mgrProcedimientosGral.bat" %serv% %db% 

rem Actualización de datos

Call ".\5.- Datos\mgrdatos.bat"                   %serv% %db% 


rem Actualización de datos a través de la aplicación de Scripts

Call ".\6.- Scripts\mgrScripts.bat"               %serv% %db% 

rem Reporte de Cargos y Abobos

Call ".\7.- Cargos y Abonos\cargosyabonos.bat" %serv% %db% 

rem Proceso de Saldos

Call ".\8.- Saldos\saldos.bat" %serv% %db% 

rem Proceso de envío de correos

Call ".\9.- Envio de Correos\EnvioCorreos.bat" %serv% %db% 

rem Migración de Procedimientos
 
Call ".\10.- Procedimientos\Procedimientos.bat" %serv% %db% 

rem Borra Bd ServicioPostal
 
osql -S  %serv% -d %dbTemp% -U %usr%  -P %pass% -E -e -i Sp_BorraBd.sql                      > Sp_BorraBd.log

osql -S  %serv% -d %dbTemp% -U %usr%  -P %pass% -E -e -Q "Drop Procedure dbo.Spp_BorraBd "  >>  Borra_proc.log


rem Ajuste Cierre

Call ".\11.- Ajuste Cierre\Ajuste Cierre.bat" %serv% %db%


If Exist ServicioPostal.bak    del ServicioPostal.bak

rem Borra archivos sql

If Exist sp_GeneraBd.sql       del sp_GeneraBd.sql
If Exist Sp_RecuperaBd.sql     del Sp_RecuperaBd.sql
If Exist sp_AsignaPermisos.sql del sp_AsignaPermisos.sql
If Exist Sp_BorraBd.sql        del Sp_BorraBd.sql


Echo "Fin de Proceso"