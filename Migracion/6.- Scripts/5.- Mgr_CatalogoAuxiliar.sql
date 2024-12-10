Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anioFin                 Integer,
   @w_error                   Integer,
   @w_mes                     Integer,
   @w_registros               Integer,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_desc_error              Varchar(Max),
--
   @w_linea                   Integer,
   @w_regCat                  Integer,
   @w_idusuario               Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = -1,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_regCat    = 0,
          @w_ultactual = Getdate();

   Select @w_anioFin = ejercicio,
          @w_anioIni = ejercicio -1
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

   Create Table #TempErrores
   (secuencia   Integer Not Null Identity (1, 1) Primary Key,
    Tabla       Sysname,
    comando     Varchar(Max),
    mensaje     Varchar(Max));

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.CatalogoAuxiliar)
         Begin
            Begin Try
               Delete dbo.CatalogoAuxiliar
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
         Select @w_mes     = -1,
                @w_anioIni = @w_anioIni + 1;

         While @w_mes < 13
         Begin
            Select @w_mes   = @w_mes + 1,
                   @w_chmes = dbo.Fn_BuscaMes (@w_mes),
                   @w_tabla = Case When @w_mes = 0
                                   Then Concat('CatAuxIni', @w_anioIni)
                                   When @w_mes = 13
                                   Then Concat('CatAuxFin', @w_anioIni)
                                   Else Concat('CatAux', @w_chmes, @w_anioIni)
                              End;

            If Ejercicio_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
               Begin
                  Goto Siguiente
               End

            Set @w_sql = Concat('Select Distinct Llave, ', @w_comilla, '00', @w_comilla, ' Moneda,   Niv,          Sector_id, ',
                                       'Sucursal_id, ',
                                       'Case When Region_id = 202 Then 5555 Else Region_id End Region_id, ',
                                       'Descrip,     SAnt, ',
                                       'Car,         Abo,        SAct,        FecCap, ',
                                       'CarProceso,  AboProceso, SAntProceso, CarExt, ',
                                       'AboExt,      SProm,      SPromAnt,    SProm2, ',
                                       'SProm2Ant, ', @w_anioIni, ', ', @w_mes, ' ',
                               'From   Ejercicio_DES.dbo.', @w_tabla, ' a ',
                               'Where  Exists      (Select Top 1 1 ',
                                                   'From   dbo.CatalogoConsolidado ',
                                                   'Where  numerodecuenta = a.llave ',
                                                   'And    Moneda_id      = ', @w_comilla, '00', @w_comilla, ') ');

            Begin Try
               Insert Into dbo.CatalogoAuxiliar
              (Llave,       Moneda,     Niv,         Sector_id,
               Sucursal_id, Region_id,  Descrip,     SAnt,
               Car,         Abo,        SAct,        FecCap,
               CarProceso,  AboProceso, SAntProceso, CarExt,
               AboExt,      SProm,      SPromAnt,    SProm2,
               SProm2Ant,   ejercicio,  mes)
               Execute(@w_sql)
               Set @w_registros = @w_registros + @@Rowcount;
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_desc_error = Error_Message()
            End   Catch

            If @w_error != 0
               Begin
                  Insert Into #TempErrores
                 (Tabla, comando, mensaje)
                 Select @w_tabla, @w_sql, @w_desc_error

                 Select @w_error      = 0,
                        @w_desc_error = '';

                 Goto Siguiente
               End
         End

Siguiente:

      End

   Commit Transaction

   Select @w_registros RegistrosAlta, @w_regCat "Registros Alta";

Salida:
    
   If Exists (Select Top 1 1
              From   #TempErrores)
      Begin
         Select *
         From   #TempErrores
      End

    Drop table #TempErrores;

    Set Xact_Abort        Off
    Return

End
Go
