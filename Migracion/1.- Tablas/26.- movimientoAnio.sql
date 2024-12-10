If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'movimientosAnio')
   Begin
      Drop Table dbo.movimientosAnio
   End
Go

Create Table dbo.movimientosAnio
   (Referencia       Varchar(20)   Not Null,
    Cons             Integer       Not Null,
    Moneda           Varchar( 2)   Not Null Default '00',
    Fecha_mov        Datetime      Not Null,
    Llave            Varchar(16)   Not Null,
    Concepto         Varchar(255)      Null,
    Importe          Decimal(19, 2)    Null Default 0,
    Documento        Varchar(255)      Null,
    Clave            Char(1)       Not Null,
    FecCap           Datetime      Not Null,
    Sector_id        Varchar(2)        Null,
    Sucursal_id      Integer           Null,
    Region_id        Integer           Null,
    Importe_Cargo    Decimal(19, 2)    Null,
    Importe_Abono    Decimal(19, 2)    Null,
    Descripcion      Varchar(150)      Null,
    TipoPolizaConta  Varchar(5)        Null,
    ReferenciaFiscal Varchar(50)       Null,
    Fecha_Doc        Datetime          Null,
    Ejercicio        Smallint      Not Null,
    mes              Tinyint       Not Null
Constraint movimientosAnioPK
Primary Key (Referencia, Cons, Fecha_mov, Ejercicio, mes),
Constraint movimientosAnioFK01
Foreign Key (Referencia, Fecha_mov, ejercicio, mes)
References dbo.polizaAnio (Referencia, Fecha_Mov, Ejercicio, Mes),
Constraint movimientosAnioFK02
Foreign Key (Sector_id)
References dbo.Sector (Sector_id),
Constraint movimientosAnioFk03
Foreign Key (Llave, moneda)
References dbo.catalogoConsolidado(numerodecuenta, moneda_id))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de Detalle de la Póliza Contable por Año.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'movimientosAnio'
Go

