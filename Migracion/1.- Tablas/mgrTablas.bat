echo declare @PnEstatus Integer = 0, @PsMensaje Varchar(250) Begin Execute dbo.Spp_GeneraBd       '%2', '%4',                    @PnEstatus Output, @PsMensaje Output; Select @PnEstatus, @PsMensaje End  > sp_GeneraBd.sql
echo declare @PnEstatus Integer = 0, @PsMensaje Varchar(250) Begin Execute dbo.Spp_RecuperaBd     'ServicioPostal', '%5', '%4',  @PnEstatus Output, @PsMensaje Output; Select @PnEstatus, @PsMensaje End  > Sp_RecuperaBd.sql
echo declare @PnEstatus Integer = 0, @PsMensaje Varchar(250) Begin Execute dbo.Spp_AsignaPermisos '%2',                          @PnEstatus Output, @PsMensaje Output; Select @PnEstatus, @PsMensaje End  > sp_AsignaPermisos.sql
echo declare @PnEstatus Integer = 0, @PsMensaje Varchar(250) Begin Execute dbo.Spp_BorraBd        'ServicioPostal',              @PnEstatus Output, @PsMensaje Output; Select @PnEstatus, @PsMensaje End  > Sp_BorraBd.sql


osql -S %1 -d %3 -E -e  -i ".\1.- Tablas\1.- Spp_GeneraBd.sql"                      >  Spp_GeneraBd.log
osql -S %1 -d %3 -E -e -i sp_GeneraBd.sql                                           >  sp_GeneraBd.log

osql -S %1 -d %3 -E -e  -i ".\1.- Tablas\1.- Spp_RecuperaBd.sql"                    >  Spp_RecuperaBd.log
osql -S %1 -d %3 -E -e -i Sp_RecuperaBd.sql                                         >  Sp_RecuperaBd.log

osql -S %1 -d %3 -E -e  -i ".\1.- Tablas\32.- Spp_BorraBd.sql"                      >  Spp_BorraBd.log


osql -S %1 -d %2 -E -e -i ".\1.- Tablas\2.- Spp_AsignaPermisos.sql"                 >  Spp_AsignaPermisos.log
osql -S %1 -d %2 -E -e -i sp_AsignaPermisos.sql                                     >  sp_AsignaPermisos.log

osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\3.- Generar Tablas.sql"                    >  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\4.- Comentarios a las Tablas.sql"         >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\5.- catMensajesErroresTbl.sql"            >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\6.- CatalogoAuxiliarHist.sql"             >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\7.- ControlReprocesoTbl.sql"              >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\8.- ControlCargoAbonoTbl.sql"             >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\9.- CatalogoNaturalezaContTbl.sql"        >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\10.- CatalogoCtasContabElectroTbl.sql"    >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\11.- AuxiliaresCorporativos.sql"          >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\12.- Bitacora_CargosAbonos.sql"           >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\13.- CatAuxErrorMgrTbl.sqll"              >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\14.- ControlSaldosTbl.sql"                >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\15.- catalogoReporteTbl.sql"              >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\16.- logImportarPolErrorTbl.sql"          >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\17.- MontoDepreciacionMensual.sql"        >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\18.- PolDiaError.sql"                     >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\19.- MovDiaError.sql"                     >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\20.- CatalogoPresupuestoTbl.sql"          >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\21.- relacion_cuenta_centro_costos.sql"   >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\22.- RelacionImp.sql"                     >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\23.- BalanzaComprobacionTbl.sql"          >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\24.- Control.sql"                         >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\25.- polizaAnio.sql"                      >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\26.- movimientoAnio.sql"                  >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\27.- xmlContabilidadElectronica.sql"      >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\28.- XmlPoliza.sql"                       >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\29.- conParametrosGralesTbl.sql"          >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\30.- controlImpPolTbl.sql"                >>  migracion_tablas.log
osql -S %1 -d %2 -E -e  -i ".\1.- Tablas\31.- Relacion_Poliza_Interna_Externa.sql" >>  migracion_tablas.log


osql -S %1 -d %3 -E -e -Q "Drop Procedure dbo.Spp_GeneraBd "                        >  Borra_proc.log
osql -S %1 -d %3 -E -e -Q "Drop Procedure dbo.Spp_RecuperaBd "                     >>  Borra_proc.log
osql -S %1 -d %2 -E -e -Q "Drop Procedure dbo.Spp_AsignaPermisos "                 >>  Borra_proc.log