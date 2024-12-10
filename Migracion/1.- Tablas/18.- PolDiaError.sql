If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'PolDiaError')
   Begin
      Drop Table dbo.PolDiaError
   End
Go

Create Table dbo.PolDiaError
  (id_Error              Integer           Not Null Identity (1, 1),
   Referencia            Varchar( 20)      Not Null,
   Fecha_Mov             Datetime          Not Null,
   Fecha_Cap             Datetime              Null,
   Concepto              Varchar(255)          Null,
   Cargos                Decimal(19, 2)        Null Default 0,
   Abonos                Decimal(19, 2)        Null Default 0,
   TCons                 Integer               Null Default 0,
   Usuario               Varchar( 10)          Null,
   TipoPoliza            Varchar(  5)      Not Null,
   Documento             Varchar(255)          Null,
   Usuario_cancela       Varchar( 10)          Null,
   Fecha_Cancela         Datetime              Null,
   Status                Tinyint           Not Null,
   Mes_Mov               Varchar(  3)          Null,
   TipoPolizaConta       Varchar(  3)          Null,
   FuenteDatos           Varchar( 50)          Null,
   Ejercicio             Smallint          Not Null,
   Mes                   Tinyint           Not Null,
   Causa_Rechazo         Varchar(512)      Not Null Default Char(32),
   Fecha_importacion     Datetime          Not Null,
   UltActal              Datetime          Not Null Default Getdate(),
Constraint PolDiaErrorPk
Primary Key(id_Error),
Index PolDiaErrorIdx01 (Referencia, Fecha_Mov, Ejercicio,  mes));
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de Seguimiento de Pólizas con Error.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'PolDiaError'
Go