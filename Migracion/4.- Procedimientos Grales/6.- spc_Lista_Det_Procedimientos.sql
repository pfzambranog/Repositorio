-- /*
-- Declare
   -- @PsProc       Varchar( 60) = 'Gener',
   -- @PnEstatus    Integer      = 0,
   -- @PsMensaje    Varchar(250) = ' ';
-- Begin
   -- Execute dbo.spc_Lista_Det_Procedimientos @PsProc    = @PsProc,
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

Create Or Alter Procedure dbo.spc_Lista_Det_Procedimientos
  (@PsProc       Varchar( 60) = Null,
   @PnEstatus    Integer      = 0    Output,
   @PsMensaje    Varchar(250) = ' '  Output)
As

Begin
   Set Nocount       On
   Set Xact_Abort    On

   create table #Tempsps(
    objeto_id              Integer,
    Procedimiento          Varchar(150),
    Posicion               Smallint,
    TipoParametro          Varchar( 10),
    NombreParametro        Varchar(100),
    TipoDato               Varchar( 30),
    Longitud               Integer,
    Precision              Integer,
    Escala                 Integer,
    Collation              Varchar(150),
    FechaCreacion          Varchar( 10),
    FechaAct               Varchar( 10));

    Insert into #Tempsps
    Select S.object_id,             P.SPECIFIC_NAME,
           P.ordinal_position,      P.PARAMETER_MODE,  P.PARAMETER_NAME,  P.DATA_TYPE,         P.CHARACTER_MAXIMUM_LENGTH,
           P.NUMERIC_PRECISION,     P.NUMERIC_SCALE,   P.COLLATION_NAME,
           Convert(Varchar(10),     R.CREATED,      121),
           Convert(Varchar(10),     R.LAST_ALTERED, 121)
    From   Information_schema.Parameters P
    Join   Information_schema.Routines R
    On     R.specific_name = P.specific_name
    Join   sys.objects S
    On     S.name = R.SPECIFIC_NAME
    Where  R.ROUTINE_TYPE = 'PROCEDURE'
    Order By P.SPECIFIC_NAME, P.ORDINAL_POSITION;

    If @PsProc Is Not Null
       Begin
          Delete #Tempsps
          Where  Procedimiento Not Like Concat('%', @PsProc, '%');
       End

    Update #Tempsps
    Set    Procedimiento     = Char(32),
           FechaCreacion     = Char(32),
           FechaAct          = Char(32)
    Where  Posicion  > 1;

    Update #Tempsps
    Set    Longitud     = Isnull(Longitud,  Char(32)),
           Precision    = Isnull(Precision, Char(32)),
           Escala       = Isnull(Escala,    Char(32)),
           Collation    = Isnull(Collation, Char(32));


    Select Procedimiento,  Posicion,           TipoParametro "Tipo Parametro",
           NombreParametro "Nombre Parametro", TipoDato      "Tipo Dato",
           Longitud,       Precision           "Precision Numerica",  Escala,     Collation,
           FechaCreacion "Fecha Creacion",   FechaAct "Fecha Últ Act"
    From   #Tempsps
    Order By objeto_id, Posicion;

    Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Lista los procedimientos compilados una BD específica.',
   @w_procedimiento  NVarchar(250) = 'spc_Lista_Det_Procedimientos';

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
