Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anioFin                 Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_regAux                  Integer,
   @w_regCat                  Integer,
   @w_registrosDup            Integer,
   @w_mes                     Tinyint,
   @w_mesProc                 Tinyint,
   @w_mesMax                  Tinyint,
   @w_linea                   Integer,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_mensaje                 Varchar(  Max),
   @w_idusuario               Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime,
   @w_inicio                  Bit;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_regAux    = 0,
          @w_regCat    = 0,
          @w_inicio    = 1,
          @w_ultactual = Getdate()

   Select @w_anioIni  = Datepart(yyyy, parametroFecha),
          @w_mesProc  = Datepart(mm,   parametroFecha)
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 11;

   Select @w_anioFin = ejercicio
   From   dbo.Control With  (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select  @w_Error   = 9999,
                 @w_mensaje = 'Error: No hay Ejercicios en Estatus 1 en la tabla control.'

         Set Xact_Abort Off
         Goto Salida
      End

   Select @w_mesMax    = Max(valor)
   From   catCriteriosTbl
   Where  criterio = 'mes'
   And    idEstatus = 1;

   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 6;

   Select @w_sql   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
          @w_param = '@o_usuario    Nvarchar(20) Output';

   Execute Sp_executeSql @w_sql, @w_param, @o_usuario = @w_usuario Output

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.Catalogo)
         Begin
            Begin Try
               Truncate table dbo.Catalogo
            End   Try

            Begin Catch
               Select  @w_Error   = @@Error,
                       @w_linea   = Error_line(),
                       @w_mensaje = Substring (Error_Message(), 1, 200)

            End   Catch

             If Isnull(@w_Error, 0) <> 0
                Begin
                   Select @w_Error Error, Concat('Error.: ', @w_Error, ' ', @w_mensaje, ' en Línea ', @w_linea) Mensaje;

                   Rollback Transaction
                   Set Xact_Abort Off
                   Goto Salida
                End

         End

       While @w_anioIni  <= @w_anioFin
       Begin

          While @w_mes <= @w_mesMax
          Begin
             If @w_inicio = 1
                Begin
                   Select @w_mes     = @w_mesProc,
                          @w_inicio  = 0;
                End

             Select @w_registrosDup = 0,
                    @w_chmes        = dbo.Fn_BuscaMes (@w_mes),
                    @w_tabla       = Case When @w_mes = 0
                                          Then Concat('catIni', @w_anioIni)
                                          When @w_mes = 13
                                          Then Concat('catFin', @w_anioIni)
                                          Else Concat('cat', @w_chmes, @w_anioIni)
                                     End;

             If Ejercicio_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
                Begin
                   Goto Siguiente
                End

             Set @w_sql = Concat('Select Distinct Llave, ', @w_comilla, '00', @w_comilla, ' Moneda,   Niv,        Descrip, ',
                                        'SAnt,         Car,        Abo,        SAct, ',
                                        'FecCap,       CarProceso, AboProceso, SAntProceso, ',
                                        'CarExt,       AboExt,     SProm,      SPromAnt, ',
                                        'Nivel_sector, SProm2,     SProm2Ant, ',
                                         @w_anioIni, ', ', @w_mes, ' ',
                                 'From   Ejercicio_DES.dbo.', @w_tabla, ' a ',
                                 'Where  Niv In (0, 1) ',
                                 'And    Exists (Select Top 1 1 ',
                                                'From   dbo.catalogoConsolidado ',
                                                'Where  numerodecuenta = a.Llave ',
                                                'And    moneda_id      = ', @w_comilla, '00', @w_comilla, ')')
             Begin Try
                Insert Into dbo.Catalogo
               (Llave,        Moneda,     Niv,        Descrip,
                SAnt,         Car,        Abo,        SAct,
                FecCap,       CarProceso, AboProceso, SAntProceso,
                CarExt,       AboExt,     SProm,      SPromAnt,
                Nivel_sector, SProm2,     Sprom2Ant,  Ejercicio,
                Mes)
                Execute(@w_sql)

                Set @w_registros = @w_registros + @@Rowcount;

             End   Try

             Begin Catch
                Select  @w_Error   = @@Error,
                        @w_linea   = Error_line(),
                        @w_mensaje = Substring (Error_Message(), 1, 200)

             End   Catch

             If Isnull(@w_Error, 0) <> 0
                Begin
                   Rollback Transaction
                   Select @w_Error Error, Concat('Error.: ', @w_Error, ' ', @w_mensaje, ' en Línea ', @w_linea) Mensaje;

                   Goto Salida
                End


             Set @w_sql = Concat('Update dbo.CatalogoConsolidado ',
                                 'Set    codigoAgrupador = b.codigoAgrupador ',
                                 'From   dbo.CatalogoConsolidado  a ',
                                 'Join   Ejercicio_DES.dbo.', @w_tabla, ' b ',
                                 'On     b.llave = a.numerodecuenta ',
                                 'Where  b.codigoAgrupador Is Not Null');

             Begin Try
                Execute(@w_sql)
                Set @w_regAux = @w_regAux + @@Rowcount;

             End   Try

             Begin Catch
                Select  @w_Error   = @@Error,
                        @w_mensaje = Error_Message()
             End Catch

             If @w_error != 0
                Begin
                   Rollback Transaction

                   Select @w_error, @w_mensaje;

                   Goto Salida
                End

             Set @w_mes += 1;

Siguiente:

          End


          Select @w_anioIni += 1,
                 @w_mes      = 0;

       End

       Begin Try
          Insert Into dbo.Ejercicios
         (Ejercicio, idEstatus)
          Select Distinct ejercicio, 0
          From   dbo.Catalogo a With (Nolock)
          Where  Not Exists ( Select Top 1 1
                              From   dbo.Ejercicios With (Nolock)
                              Where  ejercicio = a.ejercicio);
       End   Try

       Begin Catch
          Select  @w_Error   = @@Error,
                  @w_mensaje = Error_Message()
       End Catch

       If @w_error != 0
          Begin
             Rollback Transaction

             Select @w_error, @w_mensaje;

             Goto Salida
          End

       Begin Try
          Insert Into dbo.control
         (Ejercicio, Mes, idEstatus, usuario)
          Select Distinct ejercicio, mes, 0, @w_usuario
          From   dbo.Catalogo a With (Nolock)
          Where  Not Exists ( Select Top 1 1
                              From   dbo.Control With (Nolock)
                              Where  ejercicio = a.ejercicio
                              And    mes       = a.mes);
       End   Try

       Begin Catch
          Select  @w_Error   = @@Error,
                  @w_mensaje = Error_Message()
       End Catch

       If @w_error != 0
          Begin
             Rollback Transaction

             Select @w_error, @w_mensaje;

             Goto Salida
          End

   Commit Transaction

   Select @w_registros "Nuevos Registros";

Salida:

   Set Xact_Abort    On
   Return

End
Go

