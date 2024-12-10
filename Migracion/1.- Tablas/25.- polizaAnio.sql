If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'polizaAnio')
   Begin
      Drop Table dbo.polizaAnio
   End
Go

Create Table dbo.polizaAnio
   (Referencia      Varchar( 20)   Not Null,
    Fecha_Mov       Datetime       Not Null,
    Fecha_Cap       Datetime           Null,
    Concepto        Varchar(255)       Null,
    Cargos          Decimal(19,2)      Null Default 0,
    Abonos          Decimal(19,2)      Null Default 0,
    TCons           Integer            Null Default 0,
    Usuario         Varchar( 10)       Null,
    TipoPoliza      Varchar(  5)   Not Null,
    Documento       Varchar(255)       Null,
    Usuario_cancela Varchar(10)        Null,
    Fecha_Cancela   Datetime           Null,
    Status          Tinyint        Not Null,
    Mes_Mov         Varchar(  3)       Null,
    TipoPolizaConta Varchar(  3)       Null,
    FuenteDatos     Varchar( 50)       Null,
    Ejercicio       Smallint       Not Null,
    Mes             Tinyint        Not Null,
Constraint polizaAnioPK
Primary Key (Referencia, Fecha_mov, ejercicio, mes),
Constraint polizaAnioFK01
Foreign Key (TipoPoliza)
References dbo.TipoPol (Tipo),
Constraint polizaAnioFk02
Foreign Key (ejercicio)
References dbo.Ejercicios(ejercicio),
Index PolizaIdx01 (TipoPoliza));
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de Encabezado de la Póliza Diaria por Año.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'polizaAnio'
Go

