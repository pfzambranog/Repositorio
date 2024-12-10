osql -S %1 -d %2 -E  -i ".\5.- Datos\1.- Migracion Datos.sql"         >  migracion_datos.log
osql -S %1 -d %2 -E  -i ".\5.- Datos\2.- catCriterios.sql"           >>  migracion_datos.log
osql -S %1 -d %2 -E  -i ".\5.- Datos\3.- conParametrosGralesTbl.sql" >>  migracion_datos.log
osql -S %1 -d %2 -E  -i ".\5.- Datos\4.- contadores.sql"             >>  migracion_datos.log
osql -S %1 -d %2 -E  -i ".\5.- Datos\5.- catGeneralesTbl.sql"        >>  migracion_datos.log
osql -S %1 -d %2 -E  -i ".\5.- Datos\6.- Ejercicios.sql"             >>  migracion_datos.log
osql -S %1 -d %2 -E  -i ".\5.- Datos\7.- Ejercicios_Presupuesto.sql" >>  migracion_datos.log
osql -S %1 -d %2 -E  -i ".\5.- Datos\8.- Parametro_Rutas.sql"        >>  migracion_datos.log

