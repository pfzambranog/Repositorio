Declare
   @w_idError                 Integer,
   @w_anio                    Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_tabla                   Sysname,
   @w_desc_error              Varchar( 250),
   @w_regCat                  Integer,
   @w_idusuario               Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_anio      = 2024,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_regCat    = 0,
          @w_ultactual = Getdate();

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
                  From   dbo.Promedios)
         Begin
            Begin Try
               Delete dbo.Promedios
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End   Catch

            If @w_error != 0
               Begin
                  Select @w_error, @w_desc_error;
                  RollBack Transaction

                  Goto Salida
               End

         End

      Set @w_tabla = 'dbo_Promedios';

      If DB_Gen_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
         Begin
            Select 9999 Error, Concat('La tabla ', @w_tabla, ' No Existe en la BD Origen,') mensajeError
            Goto Salida
         End

     Begin Try
        Insert Into dbo.Promedios
        (Llave,   moneda_id, Ejercicio, mes,
         Sact,    Sacu,      Spro,      Sprom2,
         sfinmes, totcar,    totabo,    campo_valor)
        Select numerodecuenta, '00' moneda_mex, Round(periodo / 100, 0) ejercicio, periodo % 100 mes,
               Sact,           Sacu,         Spro,                              Isnull(Sprom2, 0),
               sfinmes,        totcar,       totabo,                            campo_valor
        From   DB_Gen_DES.dbo.dbo_Promedios
        Where  Exists (Select Top 1 1
                       From   dbo.CatalogoConsolidado a
                       Where  numerodecuenta = a.numerodecuenta
                       And    Moneda_id      = '00');

        Set @w_registros = @w_registros + @@Rowcount;
     End Try

     Begin Catch
        Select  @w_Error      = @@Error,
                @w_linea      = Error_line(),
                @w_desc_error = Substring (Error_Message(), 1, 200)

     End   Catch

     If @w_error != 0
        Begin
           Select @w_error Error, @w_desc_error mensajeError;
           RollBack Transaction

           Goto Salida
        End

   Commit Transaction

   Select @w_registros RegistrosAlta;

Salida:

   Set Xact_Abort  Off
   Return

End
Go
