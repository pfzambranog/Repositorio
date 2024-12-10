osql -S %1 -d %2 -E  -e -i ".\7.- Cargos y Abonos\1.- Add catMensajesErroresTbl.sql"   > CargosAbonos.log
osql -S %1 -d %2 -E  -e -i ".\7.- Cargos y Abonos\2.- Add dbo_parametros.sql"         >> CargosAbonos.log
osql -S %1 -d %2 -E  -e -i ".\7.- Cargos y Abonos\3.- Spp_AplicaPolizas.sql"          >> CargosAbonos.log
osql -S %1 -d %2 -E  -e -i ".\7.- Cargos y Abonos\4.- spp_ActualizaCarAbo.sql"        >> CargosAbonos.log
osql -S %1 -d %2 -E  -e -i ".\7.- Cargos y Abonos\5.- Spc_cifrasCargosAbonos.sql"        >> CargosAbonos.log
