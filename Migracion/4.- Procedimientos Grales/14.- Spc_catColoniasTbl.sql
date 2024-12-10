Create Or Alter Procedure dbo.Spc_catColoniasTbl
   (@PnIdPais                  Smallint       =    Null,
    @PnIdEstado                Smallint       =    Null,
    @PnIdCiudad                Smallint       =    Null,
    @PnIdMunicipio             Smallint       =    Null,
    @PnIdColonia               Smallint       =    Null,
    @PsNombre                  Varchar(  60)  =    Null,
    @PsAbreviatura             Varchar(   3)  =    Null,
    @PsIdCodigoPostal          Varchar(  10)  =    Null,
    @PnEstatus                 Integer       = 0   Output,
    @PsMensaje                 Varchar( 250) = ' ' Output)

As
Declare
    @w_sql               Varchar(Max),
    @w_desc_error        Varchar( 250),
    @w_Error             Integer,
    @w_primero           Bit,
    @w_comilla           Char(1)

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On

   Select @PnEstatus  = 0,
          @PsMensaje  = Null,
          @w_primero  = 0,
          @w_comilla  = Char(39)

   Set @w_sql = 'Select a.idPais,    a.idEstado, Isnull(a.idCiudad, 0) idCiudad,    a.idMunicipio, ' +
                       'a.idColonia, a.nombre    nombreColonia, a.abreviatura '                      +
                'From   dbo.catColoniasTbl a '          +
                'Join   dbo.catPaisesTbl   b '          +
                'On     b.idPais      = a.idPais '      +
                'Join   dbo.catEstadosTbl c '           +
                'On     c.idPais      = a.idPais '      +
                'And    c.idEstado    = a.idEstado '    +
                'Left   Join   dbo.catCiudadesTbl d '   +
                'On     d.idPais      = a.idPais '      +
                'And    d.idEstado    = a.idEstado '    +
                'And    d.idCiudad    = a.idCiudad '    +
                'Join   dbo.catMunicipiosTbl e '        +
                'On     e.idPais      = a.idPais '      +
                'And    e.idEstado    = a.idEstado '    +
                'And    e.idMunicipio = a.idMunicipio'

   If @PnIdPais Is Not Null
      Begin
         Select @w_primero = 1,
                @w_sql     = @w_sql + ' Where  a.idPais = ' + Cast(@PnIdPais As Varchar)
      End

   If @PnIdEstado Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql     = @w_sql + ' Where '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.idEstado = ' + Cast(@PnIdEstado As Varchar)
      End

   If @PnIdCiudad Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql     = @w_sql + ' Where '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.idCiudad = ' + Cast(@PnIdCiudad As Varchar)
      End

   If @PnIdMunicipio Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql     = @w_sql + ' Where '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.idMunicipio = ' + Cast(@PnIdMunicipio As Varchar)
      End

   If @PnIdColonia Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql     = @w_sql + ' Where '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.idColonia = ' + Cast(@PnIdColonia As Varchar)
      End

   If @PsNombre Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql     = @w_sql + ' Where  '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.nombre Like ' + @w_comilla + '%' + @PsNombre + '%' + @w_comilla
      End

   If @PsAbreviatura Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql     = @w_sql + ' Where  '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.abreviatura Like ' + @w_comilla + '%' + @PsAbreviatura + '%' + @w_comilla
      End

   If @PsIdCodigoPostal Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql     = @w_sql + ' Where  '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.IdCodigoPostal Like ' + @w_comilla + '%' + @PsIdCodigoPostal + '%' + @w_comilla
      End

   Begin Try
      Execute (@w_sql)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
         Set Xact_Abort Off
         Return
      End

   Set Xact_Abort Off
   Return
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Consulta en la entidad catColoniasTbl.',
   @w_procedimiento  NVarchar(250) = 'Spc_catColoniasTbl';

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
                                      @level0name = N'dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go
