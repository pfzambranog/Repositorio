Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anioFin                 Integer,
   @w_error                   Integer,
   @w_mes                     Integer,
   @w_registros               Integer,
   @w_regCat                  Integer,
   @w_linea                   Integer,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_desc_error              Varchar(  Max),
--
   @w_idusuario               Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime;


Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = -1,
          @w_anioIni   = 2017,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_regCat    = 0,
          @w_ultactual = Getdate();

   Select @w_anioFin = ejercicio
   From   dbo.Control With  (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select  @w_Error      = 9999,
                 @w_desc_error = 'Error: No hay Ejercicios en Estatus 1 en la tabla control.'

         Set Xact_Abort Off
         Goto Salida
      End

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
                  From   dbo.CatalogoCierreTbl)
         Begin
            Begin Try
               truncate table dbo.CatalogoCierreTbl
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

      While @w_anioIni  < @w_anioFin
      Begin
         Select @w_mes     = 13,
                @w_anioIni = @w_anioIni + 1,
                @w_tabla   = Concat('CatCie', @w_anioIni);

         If Ejercicio_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
            Begin
               Goto Siguiente
            End

         Set @w_sql = Concat('Select Distinct Llave, ', @w_comilla, '00', @w_comilla, ' Moneda,   Niv,        Descrip, ',
                                    'SAnt,         Car,        Abo,        SAct, ',
                                    'FecCap,       CarProceso, AboProceso, SAntProceso, ',
                                    'CarExt,       AboExt,     SProm,      SPromAnt, ',
                                    'Nivel_sector, SProm2,     Sprom2Ant, ',
                                     @w_anioIni, ', ', @w_mes, ' ',
                             'From   Ejercicio_DES.dbo.', @w_tabla, ' a ',
                             'Where  Exists     (Select Top 1 1 ',
                                                'From   dbo.CatalogoConsolidado ',
                                                'Where  numerodecuenta = a.llave ',
                                                'And    Moneda_id      = ', @w_comilla, '00', @w_comilla, ' ) ');
         Begin Try
            Insert Into dbo.CatalogoCierreTbl
           (Llave,        Moneda,     Niv,        Descrip,
            SAnt,         Car,        Abo,        SAct,
            FecCap,       CarProceso, AboProceso, SAntProceso,
            CarExt,       AboExt,     SProm,      SPromAnt,
            Nivel_sector, SProm2,     Sprom2Ant,  Ejercicio,
            Mes)
            Execute(@w_sql)
            Set @w_registros = @w_registros + @@Rowcount;
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)

         End   Catch

         If @w_error != 0
            Begin
               Select @w_error, @w_desc_error;

               Rollback Transaction;

               Select @w_error      = 0,
                      @w_desc_error = '';

               Goto Salida
            End

Siguiente:

      End;

   Commit Transaction;

   Select @w_registros RegistrosAlta;

Salida:


   Set Xact_Abort        Off
   Return

End
Go
