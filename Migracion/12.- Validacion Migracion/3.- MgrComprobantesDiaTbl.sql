Use DB_Siccorp_DES
Go

--
-- Objetivo:    Script de Creación de Tabla de comprobación de comprobantes Diarios contables migrados
-- Fecha:       11/12/2024
-- Programador: Pedro Zambrano.
-- Versión:     1
--

If Exists ( Select Top 1 1
            From   Sysobjects
            Where  UId  = 1
            And    Type = 'U'
            And    Name = 'MgrComprobantesDiaTbl')
   Begin
      Drop table dbo.MgrComprobantesDiaTbl
   End
Go

Create Table dbo.MgrComprobantesDiaTbl
(secuencia      Integer             Not Null Identity (1, 1),
 fechaMov       Date                Not Null,
 referencia     Varchar(20)         Not Null,
 cargosOri      Decimal(19, 2)      Not Null Default 0,
 abonosOri      Decimal(19, 2)      Not Null Default 0,
 difOrigen      Decimal(19, 2)      Not Null Default 0,
 cargosMgr      Decimal(19, 2)      Not Null Default 0,
 abonosMgr      Decimal(19, 2)      Not Null Default 0,
 difMigrada     Decimal(19, 2)      Not Null Default 0,
 diferenciaCar  Decimal(19, 2)      Not Null Default 0,
 diferenciaAbo  Decimal(19, 2)      Not Null Default 0,
 Constraint MgrComprobantesDiaPk
 Primary Key (secuencia));

Create Unique Index MgrComprobantesDiaIdx01 On MgrComprobantesDiaTbl(fechaMov, referencia);

 --
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de comprobación de comprobantes contables migrados',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Secuencia del registro a incluir',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'secuencia'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Fecha de Movimiento del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'fechaMov'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Número del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'referencia'
Go


Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Total Importe de los cargos originales del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'cargosOri'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Total Importe de los abonos originales del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'abonosOri'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Total Diferencia original del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'difOrigen'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Total Importe de los cargos migrados del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'cargosMgr'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Total Importe de los abonos migrados del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'abonosMgr'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Total Diferencia migrada del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'difMigrada'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Total Diferencia de Cargos entre el Origen y Destino del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'diferenciaCar'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Total Diferencia de Abonos entre el Origen y Destino del comprobante contable migrado',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MgrComprobantesDiaTbl',
                                  @level2type = 'Column',
                                  @level2name = N'diferenciaAbo'
Go