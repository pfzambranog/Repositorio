/*

-- Declare
   -- @PnAnio                Smallint            = 2024,
   -- @PnMes                 Tinyint             = 13,
   -- @PsUsuario             Varchar(  10)       = Null,
   -- @PnEstatus             Integer             = 0,
   -- @PsMensaje             Varchar( 250)       = ' ' ;
-- Begin

   -- Execute dbo.Spp_CierreMes @PnAnio      = @PnAnio,
                             -- @PnMes       = @PnMes,
                             -- @PsUsuario   = @PsUsuario,
                             -- @PnEstatus   = @PnEstatus Output,
                             -- @PsMensaje   = @PsMensaje Output;

   -- Select @PnEstatus, @PsMensaje
   -- Return
-- End
-- Go

--

-- Objeto:        Spp_CierreMes.
-- Objetivo:      Procedimiento que realiza el Proceso de Cierre de Mes
-- Fecha:         16/10/2024
-- Programador:   Pedro Zambrano
-- Versión:       1


*/

Create Or Alter Procedure dbo.Spp_CierreMes
  (@PnAnio                Smallint,
   @PnMes                 Tinyint,
   @PsUsuario             Varchar(  10)       = Null,
   @PnEstatus             Integer             = 0   Output,
   @PsMensaje             Varchar( 250)       = ' ' Output)
As

Declare
   @w_Error             Integer,
   @w_linea             Integer,
   @w_operacion         Integer,
   @w_idEstatus         Tinyint,
   @w_desc_error        Varchar(250),
   @w_referencia        Varchar( 20),
   @w_idusuario         Varchar(  Max),
   @w_anioAnterior      Smallint,
   @w_mesAnterior       Smallint,
   @w_anioProximo       Smallint,
   @w_mesProximo        Smallint,
   @w_mesFin            Smallint,
   @w_fechaCaptura      Datetime,
   @w_usuario           Nvarchar(  20),
   @w_sql               NVarchar(1500),
   @w_param             NVarchar( 750),
   @w_comilla           Char(1),
   @w_sucursable        Tinyint;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus         = 0,
          @PsMensaje         = Null,
          @w_operacion       = 9999,
          @w_fechaCaptura    = Getdate(),
          @w_sucursable      = Isnull(dbo.Fn_BuscaResultadosParametros(12, 'valor'), 0);

--
-- Obtención del usuario de la aplicación para procesos batch.
--

   If @PsUsuario Is Null
      Begin
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
      End
   Else
      Begin
         Set @w_usuario = @PsUsuario;
      End

--
-- Validaciones
--

   Select  Top 1 @w_idEstatus = idEstatus
   From    dbo.ejercicios With (Nolock)
   Where   ejercicio = @PnAnio;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus  = 8021,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus  = 8022,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   If Not Exists ( Select Top 1 1
                   From   dbo.catCriteriosTbl Whith (Nolock)
                   Where  criterio = 'mes'
                   And    valor    = @PnMes)
      Begin
         Select @PnEstatus  = 8023,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   Select @w_idEstatus = idEstatus
   From   dbo.control With (Nolock)
   Where  ejercicio = @PnAnio
   And    mes       = @PnMes;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus  = 8024,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus  = 8025,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

--
-- Se ubica el último ejercicio y mes Cerrado
--

   Select @w_anioAnterior = Max(ejercicio)
   From   dbo.control With (Nolock)
   Where  idEstatus = 2;

   Select @w_mesAnterior = Max(mes)
   From   dbo.control With (Nolock)
   Where  ejercicio = @w_anioAnterior
   And    idEstatus = 2;

   Select @w_mesFin = Max(valor)
   From   dbo.catCriteriosTbl Whith (Nolock)
   Where  criterio = 'mes';

--
-- Inicio de Proceso.
--

--
-- Se actualiza los saldos de Catalogo
--

   Execute dbo.Spp_actualizaSaldosMes @PnAnio      = @PnAnio,
                                      @PnMes       = @PnMes,
                                      @PsUsuario   = @w_usuario,
                                      @PnEstatus   = @PnEstatus Output,
                                      @PsMensaje   = @PsMensaje Output;

   If IsNull(@PnEstatus, 0) <> 0
      Begin
         Set Xact_Abort Off
         Goto Salida
      End

   Begin Transaction


--
-- Generación de nuevo péríodo
--

      If @w_mesFin = @PnMes
         Begin
            Select @w_mesProximo  = 0,
                   @w_anioProximo = @PnAnio + 1;

            Begin Try
               Update dbo.ejercicios
               Set    idEstatus = 1
               Where  ejercicio = @PnAnio;
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Rollback Transaction

                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Set Xact_Abort Off
                  Goto Salida
               End

            Begin Try
               Update dbo.control
               Set    idEstatus    = 1,
                      FechaProceso = @w_fechaCaptura,
                      usuario      = @w_usuario
               Where  ejercicio = @PnAnio
               And    Mes       = @PnMes;
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Rollback Transaction

                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Set Xact_Abort Off
                  Goto Salida
               End

            If Not Exists ( Select Top 1 1
                            From   dbo.Ejercicios With (Nolock)
                            Where  ejercicio = @w_anioProximo)
               Begin
                  Begin Try
                     Insert Into dbo.ejercicios
                     (ejercicio, idEstatus)
                     Select @w_anioProximo, 0
                  End Try

                  Begin Catch
                     Select  @w_Error      = @@Error,
                             @w_linea      = Error_line(),
                             @w_desc_error = Substring (Error_Message(), 1, 200)

                  End Catch

                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Rollback Transaction

                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                        Set Xact_Abort Off
                        Goto Salida
                     End

               End
            Else
               Begin
                  Begin Try
                     Update dbo.ejercicios
                     Set    idEstatus = 0
                     Where  ejercicio = @w_anioProximo
                  End Try

                  Begin Catch
                     Select  @w_Error      = @@Error,
                             @w_linea      = Error_line(),
                             @w_desc_error = Substring (Error_Message(), 1, 200)

                  End Catch

                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Rollback Transaction

                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                        Set Xact_Abort Off
                        Goto Salida
                     End
               End

            If Not Exists ( Select Top 1 1
                            From   dbo.control With (Nolock)
                            Where  ejercicio = @w_anioProximo
                            And    mes       = @w_mesProximo)
               Begin
                  Begin Try
                     Insert Into dbo.control
                     (Ejercicio, Mes, idEstatus, FechaProceso,
                      usuario)
                     Select @w_anioProximo, @w_mesProximo, 0, @w_fechaCaptura,
                            @w_usuario
                  End Try

                  Begin Catch
                     Select  @w_Error      = @@Error,
                             @w_linea      = Error_line(),
                             @w_desc_error = Substring (Error_Message(), 1, 200)

                  End Catch

                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Rollback Transaction

                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                        Set Xact_Abort Off
                        Goto Salida
                     End
               End
            Else
               Begin
                  Begin Try

                     Update dbo.control
                     Set    idEstatus    = 0,
                            FechaProceso = @w_fechaCaptura,
                            usuario      = @w_usuario
                     Where  ejercicio = @w_anioProximo
                     And    mes       = @w_mesProximo
                  End Try

                  Begin Catch
                     Select  @w_Error      = @@Error,
                             @w_linea      = Error_line(),
                             @w_desc_error = Substring (Error_Message(), 1, 200)

                  End Catch

                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Rollback Transaction

                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                        Set Xact_Abort Off
                        Goto Salida
                     End
               End
         End
      Else
         Begin
            Select @w_mesProximo  = @PnMes + 1,
                   @w_anioProximo = @PnAnio
--
            Begin Try
               Update dbo.control
               Set    idEstatus    = 2,
                      FechaProceso = @w_fechaCaptura,
                      usuario      = @w_usuario
               Where  ejercicio = @PnAnio
               And    Mes       = @PnMes;
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Rollback Transaction

                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Set Xact_Abort Off
                  Goto Salida
               End

            If Not Exists ( Select Top 1 1
                            From   dbo.control With (Nolock)
                            Where  ejercicio = @w_anioProximo
                            And    mes       = @w_mesProximo)
               Begin
                  Begin Try
                     Insert Into dbo.control
                     (Ejercicio, Mes, idEstatus, FechaProceso,
                      usuario)
                     Select @w_anioProximo, @w_mesProximo, 1, @w_fechaCaptura,
                            @w_usuario
                  End Try

                  Begin Catch
                     Select  @w_Error      = @@Error,
                             @w_linea      = Error_line(),
                             @w_desc_error = Substring (Error_Message(), 1, 200)

                  End Catch

                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Rollback Transaction

                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                        Set Xact_Abort Off
                        Goto Salida
                     End
               End
            Else
               Begin
                  Begin Try

                     Update dbo.control
                     Set    idEstatus    = 1,
                            FechaProceso = @w_fechaCaptura,
                            usuario      = @w_usuario
                     Where  ejercicio = @w_anioProximo
                     And    mes       = @w_mesProximo
                  End Try

                  Begin Catch
                     Select  @w_Error      = @@Error,
                             @w_linea      = Error_line(),
                             @w_desc_error = Substring (Error_Message(), 1, 200)

                  End Catch

                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Rollback Transaction

                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                        Set Xact_Abort Off
                        Goto Salida
                     End
               End
--
         End

--
-- Nuevo período de catalogo
--

      If Exists (Select Top 1 1
                 From   dbo.Catalogo
                 Where  ejercicio = @w_anioProximo
                 And    mes       = @w_mesProximo)
         Begin
            Begin Try
               Delete dbo.Catalogo
               Where  ejercicio = @w_anioProximo
               And    mes       = @w_mesProximo;
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Rollback Transaction

                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Set Xact_Abort Off
                  Goto Salida
               End

         End

      Begin Try
         Insert Into dbo.Catalogo
        (Llave,        Moneda,     Niv,        Descrip,
         SAnt,         Car,        Abo,        SAct,
         FecCap,       CarProceso, AboProceso, SAntProceso,
         CarExt,       AboExt,     SProm,      SPromAnt,
         Nivel_sector, SProm2,     Sprom2Ant,  Ejercicio,
         Mes)
         Select Llave,           Moneda,       Niv,          Descrip,
                SAct,            0 Car,        0 Abo,        SAct,
                @w_fechaCaptura, 0 CarProceso, 0 AboProceso, CarProceso - AboProceso,
                0 CarExt,        0 AboExt,     0 SProm,      SProm,
                Nivel_sector,    0 SProm2,     Sprom2,       @w_anioProximo,
                @w_mesProximo
         From   dbo.Catalogo With (Nolock)
         Where  ejercicio = @PnAnio
         And    mes       = @PnMes;

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

--
-- Nuevo período de catálogo Auxiliar.
--

      If Exists (Select Top 1 1
                 From   dbo.CatalogoAuxiliar
                 Where  ejercicio = @w_anioProximo
                 And    mes       = @w_mesProximo)
         Begin
            Begin Try
               Delete dbo.CatalogoAuxiliar
               Where  ejercicio = @w_anioProximo
               And    mes       = @w_mesProximo;
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Rollback Transaction

                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Set Xact_Abort Off
                  Goto Salida
               End

         End

      Begin Try
         Insert Into dbo.CatalogoAuxiliar
        (Llave,       Moneda,     Niv,         Sector_id,
         Sucursal_id, Region_id,  Descrip,     SAnt,
         Car,         Abo,        SAct,        FecCap,
         CarProceso,  AboProceso, SAntProceso, CarExt,
         AboExt,      SProm,      SPromAnt,    SProm2,
         SProm2Ant,   ejercicio,  mes)
         Select Llave,           Moneda,         Niv,                     Sector_id,
                Sucursal_id,     Region_id,      Descrip,                 SAct,
                0 Car,           0 Abo,          SAct,                    @w_fechaCaptura,
                0 CarProceso,    0 AboProceso,   CarProceso - AboProceso, CarExt,
                0 AboExt,        0 SProm,        SProm,                   0 SProm2,
                0 SProm2Ant,     @w_anioProximo, @w_mesProximo
         From   dbo.CatalogoAuxiliar With (Nolock Index (catalogoAuxiliarIdx01))
         Where  ejercicio = @PnAnio
         And    mes       = @PnMes;

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

--
-- Fin del proceso.
--

   Commit Transaction

   Set @PsMensaje = 'Cierre del Mes, realizado con éxito!'

Salida:

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Procedimiento que realiza el Proceso de Cierre de Mes',
   @w_procedimiento  Varchar( 100) = 'Spp_CierreMes'


If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'P'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)

   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'Dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento;

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'Dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go
