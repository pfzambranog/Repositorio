@echo off
rem
rem Proceso que actualiza la vista spp_movcontrolcambiosVw() en la base de datos SGCCTI
rem
rem
rem Proceso ejecutado por la tarea programada de Windows "ActReporteKpi"
rem

rem El proceso ejecuta la instrucción contenida en el script "ComandoActRep.txt"

"C:\Users\Administrador\AppData\Local\Programs\Python\Python39\python.exe"  "C:\RepKpiDesa\Fn_actualizaVistaRep1.py"