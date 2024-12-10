/*

--Declare
--   @PsIdParametro           Varchar(Max) = '[{"CodigoMotivoCorreo":"CierrePeriodo", "codigoGrupo":"GrupoCierre", "Ejercicio":2024,"mes":13,"idlogIni":1,"idlogFin":999}]',
--   @PsIdUsuarioAct          Varchar(10)  = 'omedina',
--   @PnEstatus               Integer      = 0,
--   @PsMensaje               Varchar(250);
--
--Begin
--   Execute Spp_notificaResultadoCierre @PsIdParametro  = @PsIdParametro,
--                                       @PsIdUsuarioAct = @PsIdUsuarioAct,
--                                       @PnEstatus      = @PnEstatus Output,
--                                       @PsMensaje      = @PsMensaje Output;
--
--   If @PnEstatus != 0
--      Begin
--         Select @PnEstatus As Estatus, @PsMensaje As Mensaje
--     End
--
--   Return
--
--End
--Go

-- Objetivo:    Generera la notificación del resultado del proceso de cierre.
-- Programador: Pedro Felipe Zambrano
-- Fecha:       18/09/2024
-- Versión:     1

*/

Create Or Alter Procedure dbo.Spp_notificaResultadoCierre
  (@PsIdParametro           Varchar(Max),
   @PsIdUsuarioAct          Varchar(10),
   @PnEstatus               Integer      = 0    Output,
   @PsMensaje               Varchar(250) = Null Output)
As

Declare
   @w_error                    Integer,
   @w_desc_error               Varchar(  250),
   @w_registros                Integer,
   @w_secuencia                Integer,
   @w_sql                      NVarchar( 1500),
   @w_param                    NVarchar(  750),
   @w_comilla                  Char(1),
--
   @w_idEstatus                Tinyint,
   @w_idGrupo                  Integer,
   @w_idMotivoCorreo           Integer,
   @w_CodigoMotivoCorreo       Varchar(  30),
   @w_codigoGrupoCorreo        Varchar(  20),
   @w_fechaProc                Varchar(  30),
   @w_Hora                     Time(2),
   @w_account_name             Sysname,
--
   @w_comando                  Varchar(8000),
   @w_salida                   Varchar(8000),
   @w_html                     Nvarchar(Max),
   @w_html2                    Nvarchar(Max),
--
   @w_idReceptor               Integer,
   @w_body                     Varchar(Max),
   @w_saludo                   Varchar(100),
   @w_nombre                   Varchar(100),
   @w_correo                   Varchar(100),
   @w_asunto                   Varchar(250),
   @w_observacion              Varchar(100),
   @w_idCorreo                 Integer,
   @w_registrosUser            Integer,
--
   @w_anio                     Smallint,
   @w_mes                      Tinyint,
   @w_idlogIni                 Integer,
   @w_idlogFin                 Integer,
   @w_operacion                Integer;

Begin

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Inicializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = '',
          @w_comilla            = Char(39),
          @w_secuencia          = 0,
          @w_saludo             = '<p>' + dbo.Fn_calculaSaludo(),
          @w_operacion          = 9999,
          @w_fechaProc          = Convert(Char(10), Getdate(), 103),
          @w_hora               = Getdate(),
          @w_fechaProc          = Concat(@w_fechaProc, Char(32), @w_hora);

   If IsJson(@PsIdParametro) = 0
      Begin
         Select @PnEstatus  = 135,
                @PsMensaje  = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Set Xact_Abort Off
         Return
      End

--
-- Creación de Tablas Temporales
--

   Create Table #tempParametros
  (Secuencia            Integer      Identity (1, 1) Primary Key,
   CodigoMotivoCorreo   Varchar(30)  Not Null,
   codigoGrupo          Varchar(20)  Not Null,
   Ejercicio            Smallint     Not Null,
   mes                  Tinyint      Not Null,
   idlogIni             Integer      Not Null,
   idlogFin             Integer      Not Null)

   Create Table #TempGrupoReceptorCorreoDet
   (secuencia    Integer       Not Null Identity(1, 1) Primary Key,
    correo       Varchar(250)      Null,
    nombre       Varchar(100)      Null);

--
-- Búsqueda de Parámetros.
--

   Insert Into #tempParametros
   (CodigoMotivoCorreo, codigoGrupo, Ejercicio, mes, idlogIni, idlogFin)
   Select CodigoMotivoCorreo, codigoGrupo, Ejercicio, mes, idlogIni, idlogFin
   From   OpenJson (@PsIdParametro)
   With  (CodigoMotivoCorreo   Varchar(30),
          codigoGrupo          Varchar(20),
          Ejercicio            Smallint,
          mes                  Tinyint,
          idlogIni             Integer,
          idlogFin             Integer);
   Set @w_registros = @@Rowcount

   If @w_registros = 0
      Begin
         Select @PnEstatus = 136,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Set Xact_Abort Off
         Return
      End

   If @w_registros > 1
      Begin
         Select @PnEstatus = 137,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Select  @w_CodigoMotivoCorreo = CodigoMotivoCorreo,
           @w_codigoGrupoCorreo  = codigoGrupo,
           @w_anio               = Ejercicio,
           @w_mes                = mes,
           @w_idlogIni           = idlogIni,
           @w_idlogFin           = idlogFin
   From    #tempParametros

--
-- Inicio de Proceso
--

   Select  @w_idMotivoCorreo = idMotivoCorreo,
           @w_account_name = Cast(descripcion as Sysname),
           @w_html         = html,
           @w_asunto       = titulo
   From    dbo.conMotivosCorreoTbl With (Nolock)
   Where   CodigoMotivoCorreo  = @w_CodigoMotivoCorreo;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 128,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida
      End


--
-- Validación del parámetro de Grupo de Correo.
--

   Select @w_idGrupo   = idGrupo,
          @w_idEstatus = idEstatus
   From   dbo.conGrupoReceptorCorreoTbl
   Where  codigoGrupo = @w_codigoGrupoCorreo
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 124,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus = 125,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida
      End

--
-- Consulta de los Usuarios Receptores de Correos.
--

   Begin Try
      Insert Into #TempGrupoReceptorCorreoDet
     (correo, nombre)
      Select correoReceptor, nombre
      From   dbo.conGrupoReceptorCorreoDetTbl
      Where  idGrupo   = @w_idGrupo
      And    idEstatus = 1
      Set @w_registrosUser = @@Identity
   End Try

   Begin Catch
      Select  @w_Error       = @@Error,
              @w_desc_error  = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error


         Set Xact_Abort Off
         Return
      End

   If @w_registrosUser = 0
      Begin
         Select @PnEstatus = 133,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida
     End

--

   Select @w_registros = Count(1),
          @w_error     = Sum(Case When idError != 0
                                 Then 1
                                 Else 0
                            End)
   From   dbo.logCierreInicioEjercicioTbl With (Nolock)
   Where  idLog Between @w_idlogIni And @w_idlogFin;

   If @w_registros = 0
      Begin
         Select @PnEstatus = 138,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida
     End

   If Isnull(@w_error, 0) = 0
      Begin
         Set @w_observacion = 'Termino Satisfactoriamente'
      End
   Else
      Begin
         Set @w_observacion = 'Termino con Errores'
      End

   Select @w_html = Replace(@w_html, '&saludos&',     Trim(@w_saludo)),
          @w_html = Replace(@w_html, '&Ejercicio&',   Cast(@w_anio As Varchar)),
          @w_html = Replace(@w_html, '&observacion&', Trim(@w_observacion)),
          @w_html = Replace(@w_html, '&usuario&',     Trim(@PsIdUsuarioAct)),
          @w_html = Replace(@w_html, '&fechaproc&',   Trim(@w_fechaproc));

--
-- Construcción del correo
--

   Set @w_sql = 'Select "Descripción"     = descripcion, ' +
                        '"ID Error"       = idError, '     +
                        '"Mensaje Error"  = Isnull(mensajeError, Char(32)) '   +
                'From   dbo.logCierreInicioEjercicioTbl With (Nolock) '    +
                'Where  idLog Between ' + Cast(@w_idlogIni As Varchar) + ' And ' + Cast(@w_idlogFin As Varchar)

   Execute dbo.Spp_ProcesaConsultaHtmlTable @PsConsulta   = @w_sql,
                                            @PsOrdenPres  = 'idLog ',
                                            @PsHTML       = @w_html2   Output,
                                            @PnEstatus    = @PnEstatus Output,
                                            @PsMensaje    = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Goto Salida
      End
--

   Select @w_html = @w_html +   @w_html2,
         @w_html = @w_html + '</body></html>' + '<p>NOTA: Este correo es de caracter informativo, favor de NO Replicar y NO Responder</p> ' +
       '</tbody>
   </html>'

--

   While @w_secuencia < @w_registrosUser
   Begin
      Set @w_secuencia = @w_secuencia + 1

      Select @w_nombre = nombre,
             @w_correo = correo
      From   #TempGrupoReceptorCorreoDet
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
         End

      Set @w_body = Replace(@w_html, '&Nombre&', @w_nombre);

      Execute msdb.dbo.sp_send_dbmail @profile_name          = @w_account_name,
                                      @recipients            = @w_correo,
                                      @Subject               = @w_asunto,
                                      @Body                  = @w_body,
                                      @importance            = 'High',
                                      @body_format           = 'HTML',
                                      @mailitem_id           = @w_idCorreo Output

   End
--

Salida:

   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Generera la notificación del resultado del proceso de cierre.',
   @w_procedimiento  Varchar( 100) = 'Spp_notificaResultadoCierre'


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
