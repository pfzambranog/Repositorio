osql -S %1 -d %2 -E  -e -i ".\11.- Ajuste Cierre\1.- Spp_generaAsientoAjusteCierreAnio.sql"   > mgrAjusteCierre.log
osql -S %1 -d %2 -E  -e -i ".\11.- Ajuste Cierre\2.- Spp_AjustaSaldosMes.sql"                >> mgrAjusteCierre.log
