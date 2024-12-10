-- /*
-- Declare
   -- @PsFuncion    Varchar( 60) = Null,
   -- @PnEstatus    Integer      = 0,
   -- @PsMensaje    Varchar(250) = ' ';
-- Begin
   -- Execute dbo.Spc_Lista_Det_Funciones @PsFuncion = @PsFuncion ,
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

Create Or Alter Procedure dbo.Spc_Lista_Det_Funciones
  (@PsFuncion    Varchar( 60) = Null,
   @PnEstatus    Integer      = 0    Output,
   @PsMensaje    Varchar(250) = ' '  Output)
-- With Encryption
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

     Select SCHEMA_NAME(so.SCHEMA_ID) AS Esquema,
     so.name AS [Nombre Función], 
     so.type As [Tipo Función],
     so.Type_Desc AS [Descripción Tipo Función],
     p.parameter_id AS [Id Parametro],
     p.name AS [Nombre Parametro],
     TYPE_NAME(p.user_type_id) AS [Tipo de Dato]
     , Case When p.system_type_id Not In(34, 35, 58, 61, 189) Then 
               Case When p.max_length > 0 And p.precision = 0 Then Cast(p.max_length As Varchar)
     		       When p.max_length < 0 And p.precision = 0 Then 'Max'
     		       When p.precision  > 0 And p.scale = 0 Then Cast(p.precision As Varchar) 
     			   When p.precision  > 0 And p.scale > 0 Then Cast(p.precision As Varchar) + ', ' + Cast(p.scale As Varchar)  
     		  End
     	   Else Cast(p.max_length As Varchar)
           End As [Longitud] 
     , Case When p.is_output = 1 Then 'OUT' Else 'IN' End As [Tipo Parametro] 
     From sys.objects    As so
     Join sys.parameters As p  On so.OBJECT_ID = p.OBJECT_ID
     Join sys.types      As st On st.system_type_id = p.system_type_id  And p.user_type_id = st.user_type_id 
     Where 1=1 
	 And so.TYPE IN ('FN','TF','IF')
     And so.name   like Iif(@PsFuncion  Is Null, so.name,  '%' + @PsFuncion + '%') 
	 Order By [Esquema], so.name, p.parameter_id
	 

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
   @w_valor          Nvarchar(250) = 'Procedimiento que lista las funciones de una BD.',
   @w_procedimiento  NVarchar(250) = 'Spc_Lista_Det_Funciones';

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

