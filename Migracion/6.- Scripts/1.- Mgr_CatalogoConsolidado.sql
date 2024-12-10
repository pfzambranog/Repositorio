Declare
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_idusuario               Varchar(  Max),
   @w_desc_error              Varchar(  750),
   @w_ultactual               Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   
   Set @w_ultactual = Getdate()
   
   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 6;

   Select @w_sql   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
          @w_param = '@o_usuario    Nvarchar(20) Output';

   Execute Sp_executeSql @w_sql, @w_param, @o_usuario = @w_usuario Output

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.CatalogoConsolidado)
         Begin
            Begin Try
               Delete dbo.Catalogo
               Delete dbo.CatalogoAuxiliar
			   Delete dbo.CatalogoAuxiliarHist
               Delete dbo.CatalogoAuxiliarCierreTbl
               Delete dbo.CatalogocierreTbl
               Delete dbo.CatalogoCtasContabElectroTbl
               Delete dbo.CatalogoNaturalezaContTbl
               Delete dbo.CatAuxExterno
               Delete dbo.ControlAuxiliarCC
               Delete dbo.MovDia
               Delete dbo.Movimientos
               Delete dbo.MovimientosCaptura
               Delete dbo.MovimientosErrores
               Delete dbo.MapeoCodigoAgrupador
               Delete dbo.AuxiliaresCorporativos
			   Delete dbo.MapeoCodigoAgrupador
	           Delete dbo.CatalogoAuxiliarCierre
	           Delete dbo.MovimientosHist
	           Delete dbo.BalanzaComprobacionTbl
               Delete dbo.Cuentas_predeterminadas
               Delete dbo.CatalogoConsolidado
            End Try
           
            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)
      
            End   Catch
      
            If @w_error != 0
               Begin
                  Select @w_error, @w_desc_error;
                  Rollback Transaction
      
                  Goto Salida
               End
         End

      Begin Try
         Insert Into dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id,       descripcion, interdepartamental,
         naturaleza,     CodigoAgrupador, idEstatus,   ultactual,   user_id)
         Select numerodecuenta, '00' moneda_mex, descripcion, interdepartamental,
                naturaleza,     Null CodigoAgrupador,      activo,
                @w_ultactual,   @w_usuario
         From   DB_GEN_DES.dbo.catCon
         Set @w_registros = @@Rowcount;
      End Try
     
      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If @w_error != 0
         Begin
            Select @w_error, @w_desc_error;
            Rollback Transaction

            Goto Salida
         End

   Commit Transaction

   Select @w_registros "Registros Insertados";

Salida:

   Set Xact_Abort  Off
   Return

End
Go

