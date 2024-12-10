osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\1.- activar dabasemail.sql"                    > EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\2.- Perfil_correo Saldos.sql"                 >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\3.- Alta catMensajesErroresTbl.sql"           >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\4.- conGrupoReceptorCorreoTbl.sql"            >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\5.- conGrupoReceptorCorreoDetTbl.sql"         >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\6.- trinsConGrupoReceptorCorreoDetTbl.sql"    >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\7.- Alta Grupo Correo Cierre Ejercicio.sql"   >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\8.- conMotivosCorreoTbl.sql"                  >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\9.- Fn_calculaSaludo.sql"                     >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\10.- Alta Motivo Correo Cierre Ejercicio.sql" >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\11.- Spp_ProcesaConsultaHtmlTable.sql"        >> EnvioCorreos.log
osql -S %1 -d %2 -E  -e -i ".\9.- Envio de Correos\12.- Spp_notificaResultadoCierre.sql"         >> EnvioCorreos.log