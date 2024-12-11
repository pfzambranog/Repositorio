osql -S %1 -d %2 -E -e -i ".\12.- Validacion Migracion\1.- MgrComprobantesTbl.sql.sql"                     > mgrValidaciones.log
osql -S %1 -d %2 -E -e -i ".\12.- Validacion Migracion\2.- ValidacionComprobantesMigrados.sql"            >> mgrValidaciones.log
