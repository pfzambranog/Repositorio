Declare
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_regCat                  Integer,
   @w_desc_error              Varchar(  Max),
   @w_idusuario               Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_ultactual = Getdate(),
          @w_regCat    = 0;

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

   Begin Transaction

      If Exists ( Select Top 1 1
                  From   dbo.MapeoCodigoAgrupador)
         Begin
            Begin Try
               Truncate Table dbo.MapeoCodigoAgrupador
            End   Try

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
         Insert Into dbo.MapeoCodigoAgrupador
        (Llave,             moneda_id, Niv, Descrip,
         CodigoAgrupador,   Descripcion)
        Select Llave,             '00' moneda_id, Niv, Descrip,
               CodigoAgrupador,   Descripcion
        From   DB_GEN_DES.dbo.MapeoCodigoAgrupador a
        Where  Exists (Select Top 1 1
                       From   dbo.CatalogoConsolidado
                       Where  numerodecuenta = a.llave
                       And    Moneda_id      = '00')
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

   Select @w_registros "Registros Nuevos"

Salida:

  Set Xact_Abort Off
  Return

End
Go
