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
   -- Execute dbo.Spu_catGeneralesTbl @PsTabla         = @PsTabla,
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

Create Or Alter Procedure dbo.Spu_catGeneralesTbl
   (@PsTabla              Sysname,
    @PsColumna            Sysname,
    @PnValor              Smallint,
    @PsDescripcion        Varchar(  60) = Null,
    @PbIdEstatus          Bit           = Null,
    @PnEstatus            Integer       = 0   Output,
    @PsMensaje            Varchar( 250) = ' ' Output)

As
Declare
    @w_sql               Varchar(Max),
    @w_desc_error        Varchar( 250),
    @w_Error             Integer,
    @w_operacion         Integer;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On

   Select @PnEstatus   = 0,
          @PsMensaje   = Null,
          @w_operacion = 9999;

   If Not Exists (Select Top 1 1
                  From   dbo.catGeneralesTbl
                  Where  tabla   = @PsTabla
                  And    columna = @PsColumna
                  And    valor   = @PnValor)
      Begin
         Select @PnEstatus = 1,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)
         Set Xact_Abort Off
         Return
     End

   Begin Try
      Update dbo.catGeneralesTbl
      Set    descripcion   = Isnull(@PsDescripcion, a.descripcion),
             idEstatus     = Isnull(@PbIdEstatus,   a.idEstatus),
             fechaAct      = Getdate(),
             ipAct         = dbo.Fn_BuscaDireccionIP(),
             macAddressAct = dbo.Fn_Busca_DireccionMAC()
      From   dbo.catGeneralesTbl a
      Where  tabla   = @PsTabla
      And    columna = @PsColumna
      And    valor   = @PnValor
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
   @w_valor          Nvarchar(250) = 'Procedimiento de Actualización a la entidad catGeneralesTbl.',
   @w_procedimiento  NVarchar(250) = 'Spu_catGeneralesTbl';

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
