osql -S %1 -d %2 -E -e -i ".\6.- Scripts\0.- Mgr_Control.sql"                         > mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\1.- Mgr_CatalogoConsolidado.sql"            >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\2.- Mgr_Catalogo.sql"                       >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\3.- CatalogoNaturalezaContTbl.sql"          >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\4.- CatalogoCtasContabElectroTbl.sql"       >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\5.- Mgr_CatalogoAuxiliar.sql"               >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\6.- Mgr_poliza.sql"                         >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\7.- Mgr_movimientos.sql"                    >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\8.- Mgr_CatalogoCierre.sql"                 >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\9.- Mgr_polizaAnio.sql"                     >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\10.- Mgr_polizaHist.sql"                    >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\11.- Mgr_movimientosHist.sql"               >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\12.- Mgr_MapeoCodigoAgrupador.sql"          >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\13.- Mgr_polDia.sql"                        >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\14.- Mgr_movDia.sql"                        >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\15.- Mgr_Promedios.sql"                     >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\16.- Mgr_AuxiliaresCorporativos.sql"        >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\17.- Mgr_Cuentas_predeterminadas.sql"       >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\18.- Mgr_xmlContabilidadElectronica.sql"    >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\19.- Mgr_XmlPoliza.sql"                     >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\20.- Mgr_polizaCierre.sql"                  >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\21.- Mgr_movimientosCierre.sql"             >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\22.- Mgr_ControlCierreTbl.sql"              >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\23.- Mgr_ControlPoliza.sql"                 >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\24.- Mgr_PolDiaError.sql"                   >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\25.- Mgr_MovDiaError.sql"                   >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\26.- Mgr_CatalogoAuxiliarCierreTbl.sql"     >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\27.- Mgr_CatalogoAuxiliarCierre.sql"        >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\28.- Mgr_relacion_cuenta_centro_costos.sql" >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\29.- Mgr_RelacionImp.sql"                   >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\30.- Mgr_BalanzaComprobacionTbl.sql"        >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\31.- Mgr_movimientosAnio.sql"               >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\32.- Mgr_CatalogoAuxiliarHist.sql"          >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\33.- Mgr_controlImpPolTbl.sql"              >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\34.- Relacion_Poliza_Interna_Externa.sql"   >> mgrScripts.log
osql -S %1 -d %2 -E -e -i ".\6.- Scripts\35.- Depura Datos Historicos.sql"           >> mgrScripts.log


