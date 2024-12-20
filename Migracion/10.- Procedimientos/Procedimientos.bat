osql -S %1 -d %2 -E  -e -i ".\10.- Procedimientos\1.- sp_ImportarPolizas.sql"        > mgrProcedimientos.log
osql -S %1 -d %2 -E  -e -i ".\10.- Procedimientos\2.- Spp_ExportaContabilidad.sql"  >> mgrProcedimientos.log
