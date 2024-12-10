Declare
   @w_error                   Integer,
   @w_registros               Integer,
   @w_regCat                  Integer,
   @w_linea                   Integer,
   @w_desc_error              Varchar(  Max),
   @w_idusuario               Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 6;

   Select @w_sql   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
          @w_param = '@o_usuario    Nvarchar(20) Output';

   Begin Try
      Execute Sp_executeSql @w_sql, @w_param, @o_usuario = @w_usuario Output
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If @w_error != 0
      Begin
         Select @w_error, @w_desc_error;

         Goto Salida
      End

   If Exists ( Select Top 1 1
               From   dbo.CatalogoCtasContabElectroTbl)
      Begin
         Begin Try
            Truncate table dbo.CatalogoCtasContabElectroTbl
         End Try
      
         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Error_Message()
         End   Catch
      
         If @w_error != 0
            Begin
               Select @w_error, @w_desc_error;
      
               Goto Salida
            End
      End

   Begin Transaction


      Begin Try
         Insert Into dbo.CatalogoCtasContabElectroTbl
        (CodigoAgrupador, llave, moneda_id, descripcion,
         nivel,           naturaleza)
        Select CodigoAgrupador, llave,       '00' moneda_id, Descrip,
               nivel,           naturaleza
        From   ejercicio_des.dbo.CatCuentasContaElec a
        Where  Exists ( Select Top 1 1
                        From   dbo.CodigoAgrupadorSAT
                        Where  CodigoAgrupador = a.CodigoAgrupador)
        And    Exists (Select Top 1 1
                       From   dbo.catalogoConsolidado
                       Where  numerodecuenta = a.Llave 
                       And    moneda_id      = 1)
        Set @w_registros = @@Rowcount
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

   Select @w_registros "Registros Nuevos", @w_regCat "Nuevos Registros"
   
Salida:

  Set Xact_Abort    Off
  Return

End
Go
