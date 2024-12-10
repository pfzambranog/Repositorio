-- /*
-- Declare
   -- @PsProc       Varchar( 60) = Null,
   -- @PnEstatus    Integer      = 0,
   -- @PsMensaje    Varchar(250) = ' ';
-- Begin
   -- Execute dbo.Spc_Lista_Param_Procedimientos @PsProc    = @PsProc ,
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

Create Or ALter Procedure dbo.Spc_Lista_Param_Procedimientos
  (@PsProc       Varchar( 60) = Null,
   @PnEstatus    Integer      = 0    Output,
   @PsMensaje    Varchar(250) = ' '  Output)
-- With Encryption
As
Begin
   Set Nocount       On
   Set Xact_Abort    On

   Create Table #tempSps(
    Id                   Integer Identity(1,1) Primary Key,
    Procedimiento        Varchar(150),
    Parametro_Orden      Smallint,
    Nombre_Parametro     Varchar(100),
    Tipo_Dato            Varchar(30),
    Longitud_Caracter    Integer,
    Precision_Numerica   Integer,
    Escala               Integer,
    Collation            Varchar(150),
    Set_Caracteres       Varchar(50),
    Tipo_Parametro       Varchar(10));

   Insert Into #tempSps
       (Procedimiento,            Parametro_Orden,        Nombre_Parametro,
        Tipo_Dato,   Longitud_Caracter,    Precision_Numerica,     Escala,
        Collation,   Set_Caracteres,       Tipo_Parametro)
   Select a.name,              b.ordinal_position,    b.parameter_name,
          b.data_type,         b.character_maximum_length,   b.numeric_precision,   b.numeric_scale,
          b.collation_name,    b.character_set_name,         b.parameter_modE
   From  sys.procedures a
   Join  INFORMATION_SCHEMA.PARAMETERS b
   On    b.specific_name = a.name
   Where a.type      = 'P'
--    And   a.name not in ('sp_alterdiagram','sp_creatediagram','sp_dropdiagram','sp_helpdiagramdefinition','sp_helpdiagrams','sp_renamediagram','sp_upgraddiagrams')
   Order by a.name, b.ORDINAL_POSITION

   If @PsProc  Is Not Null
      Begin
         Delete #Tempsps
         Where  Procedimiento Not Like Concat('%', @PsProc , '%');
      End

   Update #tempSps
   Set    Procedimiento = ''
   Where  Parametro_Orden > 1

   Select Procedimiento,               Parametro_Orden,
          Nombre_Parametro,                                                       Tipo_Dato,
          Case When IsNull(Cast(Longitud_Caracter As Varchar),'') = '-1'
               Then 'Max'
               Else IsNull(Cast(Longitud_Caracter As Varchar),'')
          End As Longitud_Caracter,
          IsNull(Cast(Precision_Numerica As Varchar),'') Precision_Numerica,
          IsNull(Cast(Escala As Varchar),'') Escala,
          IsNull(Cast(Collation As Varchar),'')          Collation,
          IsNull(Cast( Set_Caracteres As Varchar),'')    Set_Caracteres,          Tipo_Parametro
   From #tempSps;

   Return
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que consulta los Parametros de los Procedimientos de una BD.',
   @w_procedimiento  NVarchar(250) = 'Spc_Lista_Param_Procedimientos';

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

