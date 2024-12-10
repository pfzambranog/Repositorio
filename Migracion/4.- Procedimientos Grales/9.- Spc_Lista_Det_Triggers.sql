-- /*
-- Declare
   -- @PsTabla      Varchar( 60) = 'catGeneralesTbl',
   -- @PnEstatus    Integer      = 0,
   -- @PsMensaje    Varchar(250) = ' ';
-- Begin
   -- Execute dbo.Spc_Lista_Det_Triggers @PsTabla   = @PsTabla ,
                                      -- @PnEstatus = @PnEstatus Output,
                                      -- @PsMensaje = @PsMensaje Output;
   -- If @PnEstatus != 0
      -- Begin
         -- Select @PnEstatus, @PsMensaje;
      -- End

   -- Return

-- End
-- Go
-- */

Create Or Alter Procedure dbo.Spc_Lista_Det_Triggers
  (@PsTabla      Varchar( 60) = Null,
   @PnEstatus    Integer      = 0    Output,
   @PsMensaje    Varchar(250) = ' '  Output)
As
Declare
   @w_Error             Integer,
   @w_desc_error        Varchar( 250)

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On

   Begin Try

     Select
         db_name() [Base de Datos]
         , OBJECT_NAME(so.parent_obj) AS [Nombre Tabla]
         , so.name AS [Nombre Trigger]
         , USER_NAME(so.uid) AS [Propietario]
         , s.name AS [Esquema]
     	 , Case When OBJECTPROPERTY(id, 'ExecIsTriggerDisabled')  = 0 Then 'Si' Else 'No' End As [Habilitado]
         , Case When OBJECTPROPERTY(id, 'ExecIsInsteadOfTrigger') = 1 Then 'Si' Else 'No' End As [InsteadOf]
         , Case When OBJECTPROPERTY(id, 'ExecIsAfterTrigger')     = 1 Then 'Si' Else 'No' End As [After]
     	 , Case When OBJECTPROPERTY(id, 'ExecIsInsertTrigger')    = 1 Then 'Si' Else 'No' End As [Insert]
         , Case When OBJECTPROPERTY(id, 'ExecIsUpdateTrigger')    = 1 Then 'Si' Else 'No' End As [Update]
         , Case When OBJECTPROPERTY(id, 'ExecIsDeleteTrigger')    = 1 Then 'Si' Else 'No' End As [Delete]
     From  sysobjects  so
     Join  sysusers      On so.uid        = sysusers.uid
     Join  sys.tables  t On so.parent_obj = t.object_id
     Join  sys.schemas s On t.schema_id   = s.schema_id
     WHERE 1=1
	 And so.type = 'TR'
	 And OBJECT_NAME(so.parent_obj)  = Iif(@PsTabla  Is Null, OBJECT_NAME(so.parent_obj),  @PsTabla)

    End Try

	Begin Catch
       Select  @w_Error      = @@Error,
               @w_desc_error = Substring (Error_Message(), 1, 230)
    End   Catch

    If Isnull(@w_Error, 0) <> 0
       Begin
          Select @PnEstatus = @w_Error,
                 @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
          Select @PsMensaje

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
   @w_valor          Nvarchar(250) = 'Procedimiento que lista lod disparadores de una BD.',
   @w_procedimiento  NVarchar(250) = 'Spc_Lista_Det_Triggers';

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
