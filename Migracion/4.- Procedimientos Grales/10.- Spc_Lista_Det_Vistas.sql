-- /*
-- Declare
   -- @PsVista      Varchar( 60) = Null,
   -- @PnEstatus    Integer      = 0,
   -- @PsMensaje    Varchar(250) = ' ';
-- Begin
   -- Execute dbo.Spc_Lista_Det_Vistas @PsVista   = @PsVista,
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

Create Or Alter Procedure Spc_Lista_Det_Vistas
  (@PsVista      Varchar( 60) = Null,
   @PnEstatus    Integer      = 0    Output,
   @PsMensaje    Varchar(250) = ' '  Output)
-- With Encryption
As

Declare
  C_tablas Cursor For
  Select   Name, id
  from     Sysobjects 
  Where    Uid     = 1
  And      Type    = 'V'
  And      Name    = Case When @PsVista Is Null
                          Then Name
                     Else @PsVista
                 End
  Order    By 1

Declare
   @w_tabla             Sysname,
   @w_columna           Sysname,
   @w_idTabla           Integer,
   @w_column_id         Integer,
   @w_TipoCampo         Varchar(250),
   @w_Longitud          Integer,
   @w_Decimales         Integer,
   @w_requerido         Char(2),
   @w_aplica            Bit,
   @w_desc_error        Varchar( 250),
   @w_Error             Integer,
   @w_descripcion       NVarchar(1500),
   @w_dependencias      NVarchar(1500) 

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On

   Create table #Tmp_Objectos
   (Orden             SmallInt        Not Null,
    BaseDatos         Sysname         Default ' ',
    Objeto            Sysname         Default ' ', 
    Tabla             Sysname         Default ' ',
    idcolumna         Integer         Null,
    Columna           Sysname         Default ' ',
    Tipo              Varchar(  250)  Default ' ',
    Longitud          Varchar   (20)  Default ' ',
    Decimales         Varchar(   20)  Default ' ',
    Descripcion       NVarchar(1500)  Default ' ',
	Dependencias      NVarchar(1500)  Default ' ')

   Insert Into #Tmp_Objectos
   (Orden, BaseDatos, Descripcion)
   Select 0, db_Name(), (Select Cast(Value As NVarchar(1550))
   From   fn_listextendedproperty('MS_Description', Null, Null, Null, Null, 
              Null, Null))

   Open  C_tablas
   While @@Fetch_status < 1
   Begin
      Fetch C_tablas Into @w_tabla, @w_idTabla
      If @@Fetch_status <> 0
         Begin
            Break
         End

      Set @w_descripcion = ''

      Select @w_descripcion = Cast(Value As NVarchar(1550))
      From   fn_listextendedproperty('MS_Description', 'Schema', 'dbo', 'table', @w_tabla, 
              Null, Null)

      Select @w_dependencias = Stuff
      (
       (
        Select ', ' + 
        Iif(t.referenced_server_name Is Null,'',  t.referenced_server_name+'.')   + 
        Iif(t.referenced_database_name Is Null,'',t.referenced_database_name+'.') +
        Iif(t.referenced_schema_name Is Null,'',  t.referenced_schema_name+'.')   + 
        t.referenced_entity_name 
        From sys.sql_expression_dependencies As t
        Where t.referencing_id = @w_idTabla
        For XML Path (''), Type
       ).value('.', 'varchar(max)'), 1, 1, '')

      Insert Into #Tmp_Objectos
      (Orden, Objeto, tabla, Descripcion, Dependencias)
      Values (1, @w_tabla, @w_tabla, @w_descripcion, @w_dependencias)
      
      Declare
         C_columnas Cursor For
           Select Name, Column_id
           From   sys.columns 
           Where  Object_id = @w_idTabla
           Order  By Column_id
           
      Begin
         Open   C_columnas
         While  @@Fetch_Status < 1
         Begin
            Fetch C_columnas Into @w_columna, @w_column_id
            If @@Fetch_status <> 0
               Begin 
                  Break
               End

            Set @w_descripcion = ' '

            Select @w_descripcion = Cast(Value As NVarchar(1550))
            From   fn_listextendedproperty('MS_Description', 'Schema', 'dbo', 'table', @w_tabla, 
                    'Column', @w_columna)
            
            Execute Spc_valida_longitud @w_Tabla,     @w_Columna,   
                                        @w_Aplica     Output,
										@w_TipoCampo  Output,
										@w_Longitud   Output,
                                        @w_Decimales  Output,     
									    @w_requerido  Output, 
									    @PnEstatus    Output,
                                        @PsMensaje    Output 
  
            If @PnEstatus = 0
               Begin
                  Begin Try
                     Insert Into #Tmp_Objectos
                    (Orden,             Objeto,      idcolumna,  Columna,      Tipo,       Longitud,  Decimales, Descripcion)
                     Select  2, @w_tabla, @w_column_id, @w_columna, @w_TipoCampo,
                            Cast(@w_longitud As Varchar(20)), 
                            Case When @w_decimales = 0
                                 Then ' '
                                 Else Cast(@w_decimales As Varchar)
                            End,
							@w_descripcion  
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
               End
            Else
               Begin
                  Select @PnEstatus, @PsMensaje
               End
         End
         Close      C_columnas
         Deallocate C_columnas
      End
      
   End
   Close      C_tablas
   Deallocate C_tablas
   
   Select Tabla "Vista", Columna, tipo "Tipo de Dato", Case When longitud = -1 
                                                            Then 'Max'
                                                            Else longitud
                                                        End +
                                                           Case When Decimales != ' '
                                                           Then ', ' + Decimales
                                                           Else ' '
                                                       End Longitud,
		  Descripcion "Descripción", Dependencias 
   From   #Tmp_Objectos
   Order By Objeto, idcolumna
   
   Return
   
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Lista el detalle de las vistas.',
   @w_procedimiento  NVarchar(250) = 'Spc_Lista_Det_Vistas';

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
