
/*
-- Declare
--    @PsConsulta           NVarchar(Max) = 'Select * from ',
--    @PsOrdenPres          NVarchar(Max) = Null,
--    @PsHTML               NVarchar(Max) = Null,
--    @PnEstatus            Integer       = 0,
--    @PsMensaje            Varchar(250)  = Null
-- Begin
--    Execute dbo.Spp_ProcesaConsultaHtmlTable @PsConsulta  = @PsConsulta,
--                                             @PsOrdenPres = @PsOrdenPres,
--                                             @PsHTML      = @PsHTML    Output,
--                                             @PnEstatus   = @PnEstatus Output,
--                                             @PsMensaje   = @PsMensaje Output;
--    If @PnEstatus != 0
--       Begin
--          Select @PnEstatus As Error, @PsMensaje As Mensaje;
--       End
-- 
--    Return
-- 
-- End;
-- Go
-- 
-- 
-- 
-- Objetivo:    Construye una tabla XML desde una consulta SQL para presentarla en HTML.
-- Programador: Pedro Felipe Zambrano
-- Fecha:       18/09/2024
-- Versión:     1

*/


Create Or Alter Procedure dbo.Spp_ProcesaConsultaHtmlTable
  (@PsConsulta           NVarchar(Max),
   @PsOrdenPres          NVarchar(Max) = Null,
   @PsHTML               NVarchar(Max) = Null Output,
   @PnEstatus            Integer       = 0    Output,
   @PsMensaje            Varchar(250)  = Null Output)
As

Declare
   @w_desc_error        Varchar( 250),
   @w_error             Integer,
   @w_linea             Integer,
   @w_consulta          NVarchar(Max),
   @w_sql               Varchar(Max),
   @w_comilla           Char(1),
   @w_tabla             Sysname,
   @w_registros         Integer,
   @w_secuencia         Integer,
   @w_columna           Sysname,
   @w_titcol            Sysname,
   @w_columnas          NVarchar(Max),
   @w_param             NVarchar(750),
   @w_titulosCol        NVarchar(Max),
   @w_idTipo            Integer;

Begin

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Inicializamos Variables
--

   Select @PnEstatus    = 0,
          @PsMensaje    = '',
          @w_comilla    = Char(39),
          @w_secuencia  = 0,
          @PsOrdenPres  = Isnull(@PsOrdenPres, ''),
          @w_tabla      = 'TmpHtml_' + Substring(Replace(Cast(newid() As Varchar(100)), '-', ''), 1, 30);

--
-- Creación de Tablas de Trabajo.
--

   Create Table #TempTabla
   (secuencia           Integer  Not Null Identity (1, 1) Primary Key,
    nombre              Sysname,
    idTipo              Integer);

--

   If Exists ( Select Top 1 1
               From   sys.objects
               Where  name = @w_tabla)
      Begin
         Set @w_sql = 'Drop Table ' + @w_tabla
         Execute(@w_sql)
      End

   Set @w_sql = 'Select *
                 Into   ' + @w_tabla + '
                 From (' + @PsConsulta + ') sub;';

   Begin Try
      Execute(@w_sql);
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch
   
   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);
   
         Set Xact_Abort Off
         Return
   
      End

   Set @w_sql = 'Alter Table ' + @w_tabla + ' Add secuencia Integer Not Null Identity (1, 1) Primary Key'
   Execute(@w_sql)

   Set @w_sql = 'Select name, system_type_id
                 From   sys.columns
                 Where  object_id = object_id(' + @w_comilla + @w_tabla + @w_comilla + ')
                 And    name     != ' + @w_comilla + 'secuencia' + @w_comilla + '
                 Order  By column_id'

   Begin Try
      Insert Into #TempTabla
      (nombre, idTipo)
      Execute (@w_sql)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch
   
   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);
   
         Set Xact_Abort Off
         Return
   
      End

   Set @w_registros = @@Identity

   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1
      Select @w_columna = Concat('[', nombre, '] As ', @w_comilla, 'td', @w_comilla),
             @w_titcol  = nombre,
             @w_idTipo  = idTipo
      From   #TempTabla
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
         End

      If @w_secuencia = 1
         Begin
            Select @w_columnas   = @w_columna,
                   @w_titulosCol = @w_titcol
         End
      Else
         Begin
            Set @w_titulosCol = Concat(@w_titulosCol, '<th>', @w_titcol, '</th>')

            If @w_idTipo In (56, 52, 48)
               Begin
                  Set @w_columnas   = Concat(@w_columnas, ', ', @w_comilla, '', @w_comilla + ', ', @w_columna)
               End
            Else
               Begin
                  Set @w_columnas   = Concat(@w_columnas, ', ', @w_comilla, '', @w_comilla + ', ', @w_columna)
               End
         End

   End

   Select @w_columnas = 'Select @PsSalida= Cast((Select ' + @w_columnas + '
                                                 From   ' + @w_tabla    + '
                                                 For    XML Path(' + @w_comilla + 'tr' + @w_comilla + ')) As NVarchar(Max))',
          @w_param    = N'@PsSalida NVarchar(Max) Output'

   Execute sys.sp_executesql @w_columnas, @w_param, @PsSalida = @PsHTML Output

   Set @w_titulosCol = Concat('<th>',@w_titulosCol, '</th>')

   Set @PsHTML = Concat('<table bOrder="1">', @w_titulosCol, @PsHTML,'</table>')

   Set @w_sql = 'Drop Table ' + @w_tabla
   Execute(@w_sql)

  Set Xact_Abort Off
  Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Construye una tabla XML desde una consulta SQL para presentarla en HTML.',
   @w_procedimiento  Varchar( 100) = 'Spp_ProcesaConsultaHtmlTable'


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

