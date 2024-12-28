osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\1.- logCierreInicioEjercicioTbl.sql"    > Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\2.- conParametrosGralesTbl.sql"        >> Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\3.- Spp_generaAsientoCierreAnio.sql"   >> Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\4.- Spp_actualizaSaldosMes.sql"        >> Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\5.- Spp_actualizaInicioEjercicio.sql"  >> Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\6.- Spp_InicioEjercicio.sql"           >> Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\7.- Spp_CierreMes.sql      "           >> Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\8.-Job FinalizaEjercicio.sql"          >> Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\9.- Spp_recalculoNivelCatalogo.sql"    >> Saldos.log
osql -S %1 -d %2 -E  -e -i ".\8.- Saldos\10.- RecalculoCatalogo.sql"            >> Saldos.log