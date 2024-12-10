If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'MovDiaError')
   Begin
      Drop Table dbo.MovDiaError
   End
Go

Create Table dbo.MovDiaError
 (idError               Integer          Not Null Identity (1, 1),
  Referencia            Varchar(20)      Not Null,
  Cons                  Integer          Not Null,
  Moneda                Varchar( 2)      Not Null Default '00',
  Fecha_mov             Datetime         Not Null,
  Llave                 Varchar(16)      Not Null,
  Concepto              Varchar(255)         Null,
  Importe               Decimal(19, 2)       Null,
  Documento             Varchar(255)         Null,
  Clave                 Char(1)          Not Null,
  FecCap                Datetime         Not Null,
  Sector_id             Varchar(2)           Null,
  Sucursal_id           Integer              Null,
  Region_id             Integer              Null,
  Importe_Cargo         Decimal(19, 2)       Null,
  Importe_Abono         Decimal(19, 2)   Not Null,
  Descripcion           Varchar(150)         Null,
  TipoPolizaConta       Varchar(  3)         Null,
  ReferenciaFiscal      Varchar( 50)         Null,
  Fecha_Doc             Datetime             Null,
  Ejercicio             Smallint         Not Null,
  Mes                   Tinyint          Not Null,
  Causa_Rechazo         Varchar(512)     Not Null,
  Fecha_importacion     Datetime         Not Null,
  UltActal              Datetime         Not Null Default Getdate(),
Constraint MovDiaErrorPk
Primary Key (idError),
Index  MovDiaErrorIdx01 (Referencia, Cons, Fecha_mov, Llave, Ejercicio, Mes));

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de Seguimiento de detalles de Pólizas con Error.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MovDiaError'
Go
