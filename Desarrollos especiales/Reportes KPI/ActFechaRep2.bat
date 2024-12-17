@echo off
rem
rem PROCESO DE GENERACIÓN DE SOLICITUD DE NOTIFICACIÓN DE FIN DE MES. CONCEPTO.: INFORMA LA DISPONIBILIDAD DE INFORMACIÓN 
rem DEL REPORTE KPI DE PROGRAMADORES.
rem
rem Proceso es ejecutado por la tarea programada de Windows "AvisoActRepKPI"
rem

rem El proceso ejecuta la instrucción contenida en el script "ComandoRep4.txt"

"C:\Users\Administrador\AppData\Local\Programs\Python\Python39\python.exe"  "C:\RepKpiDesa\Fn_actualizaFechasRep4.py"