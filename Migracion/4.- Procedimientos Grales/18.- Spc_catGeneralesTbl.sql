-- /*
-- Declare
    -- @PsTabla             Sysname       = Null,
    -- @PsColumna           Sysname       = Null,
    -- @PnValor             Integer       = Null,
    -- @PsDescripcion       Varchar( 100) = Null,
    -- @PbIdEstatus         Bit           = Null,
    -- @PnEstatus           Integer       = 0,
    -- @PsMensaje           Varchar( 250) = ' ';
-- Begin
   -- Execute dbo.Spc_catGeneralesTbl @PsTabla         = @PsTabla,
                                   -- @PsColumna       = @PsColumna,
                                   -- @PnValor         = @PnValor,
                                   -- @PsDescripcion   = @PsDescripcion,
                                   -- @PbIdEstatus     = @PbIdEstatus,
                                   -- @PnEstatus       = @PnEstatus  Output,
                                   -- @PsMensaje       = @PsMensaje  Output;
   -- If @PnEstatus != 0
      -- Begin
         -- Select @PnEstatus, @PsMensaje
      -- End;

   -- Return
-- End
-- Go


-- */

Create Or Alter Procedure dbo.Spc_catGeneralesTbl
   (@PsTabla           Sysname       = Null,
    @PsColumna         Sysname       = Null,
    @PnValor           Integer       = Null,
    @PsDescripcion     Varchar( 100) = Null,
    @PbIdEstatus       Bit           = Null,
    @PnEstatus         Integer       = 0   Output,
    @PsMensaje         Varchar( 250) = ' ' Output)

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

   Set @w_sql = 'Select a.tabla,        a.columna,  a.valor,  a.descripcion, a.idEstatus, '              +
                       'Case When a.idestatus = 1
                             Then ' + @w_comilla + 'Activo'   + @w_comilla + ' ' +
                            'Else ' + @w_comilla + 'INACTIVO' + @w_comilla + ' ' +
                       'End estatus '                                            +
                'From  dbo.catGeneralesTbl a '

   If Isnull(Rtrim(Ltrim(@PsTabla)), ' ') != ' '
      Begin
         Select @w_primero = 1,
                @w_sql     = @w_sql + ' Where Tabla Like ' + @w_comilla + '%' + @PsTabla + '%' + @w_comilla
      End

   If Isnull(Rtrim(Ltrim(@PsColumna)), ' ') != ' '
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

         Set @w_sql = @w_sql + ' Columna Like ' + @w_comilla + '%' + @PsColumna + '%' + @w_comilla
      End

   If Isnull(@PnValor, -1) != -1
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

         Set @w_sql = @w_sql + ' Valor = ' + Cast(@PnValor As Varchar)
      End

   If Isnull(Rtrim(Ltrim(@PsDescripcion)), ' ') != ' '
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

         Set @w_sql = @w_sql + ' Descripcion Like ' + @w_comilla + '%' + @PsDescripcion + '%' + @w_comilla
      End

   If @PbIdEstatus Is Not Null
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

         Set @w_sql = @w_sql + ' a.idEstatus = ' + Cast(@PbIdEstatus as Varchar)
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
   @w_valor          Nvarchar(250) = 'Procedimiento de Consulta a la entidad catGeneralesTbl.',
   @w_procedimiento  NVarchar(250) = 'Spc_catGeneralesTbl';

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
