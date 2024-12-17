@echo off
rem
rem PROCESO DE ACTUALIZACIÓN MENSUAL DE DATOS DEL REPORTE DE KPI DE PROGRAMADORES
rem
rem
rem Proceso ejecutado por la tarea programada de Windows "ActFechaRepKpi"
rem

rem Paso 1. Borrado físico del archivo "instruccion3.txt"

IF Exist instruccion3.txt del instruccion3.txt

rem -----------------------------------------------------------------------------------------------------------------------------------

rem Paso 2. Actualización de las fechas de proceso del reporte la tabla repParametrosFechaTbl de la base de datos SGCCTI

"C:\Users\Administrador\AppData\Local\Programs\Python\Python39\python.exe"  "C:\RepKpiDesa\Fn_actualizaFechasRep0.py" 

rem -----------------------------------------------------------------------------------------------------------------------------------

rem Paso 3. Generación del archivo "instruccion3.txt", consulta a la tabla repParametrosFechaTbl, mediante la ejecución del archivo "ComandoRep.txt"

"C:\Users\Administrador\AppData\Local\Programs\Python\Python39\python.exe"  "C:\RepKpiDesa\Fn_actualizaFechasRep1.py"

rem -----------------------------------------------------------------------------------------------------------------------------------

rem Paso 4. Ejecuta la Actualización de la entidad repParametrosFechaTbl que se encuentra en la base de datos NCTI.
rem         Mediante la ejecución del Script "instruccion3.txt" Generado en el paso anterior.

"C:\Users\Administrador\AppData\Local\Programs\Python\Python39\python.exe"  "C:\RepKpiDesa\Fn_actualizaFechasRep2.py"

rem -----------------------------------------------------------------------------------------------------------------------------------

rem Paso 5. Realiza la solicitud de notificación mendiante la ejecución del script ComandoRep3.txt


"C:\Users\Administrador\AppData\Local\Programs\Python\Python39\python.exe"  "C:\RepKpiDesa\Fn_actualizaFechasRep3.py"