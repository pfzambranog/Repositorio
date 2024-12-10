
/****** Object:  Table dbo.catMensajesErroresTbl    Script Date: 25/07/2024 11:14:03 a. m. ******/
SET ANSI_NULLS        ON
SET QUOTED_IDENTIFIER ON

If Object_id(N'dbo.catMensajesErroresTbl', 'U') Is Not Null
    Drop Table dbo.catMensajesErroresTbl;

Create Table dbo.catMensajesErroresTbl(
    idFormulario Smallint     Not Null,
    idError      Smallint     Not Null,
    mensaje      Varchar(250) Not Null,
    idUsuarioAct Smallint     Not Null Default 1,
    fechaAct     Datetime     Not Null Default Getdate(),
    ipAct        Varchar(30)      Null,
 Constraint catMensajesErroresPk
 PRIMARY KEY CLUSTERED
(idFormulario, idError )
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = ROW)
)
Go

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del Formulario relacionado el mensaje de error' , @level0type=N'Schema',@level0name=N'dbo', @level1type=N'Table',@level1name=N'catMensajesErroresTbl', @level2type=N'Column',@level2name=N'idFormulario'
Go
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del Mensaje de Error' , @level0type=N'Schema',@level0name=N'dbo', @level1type=N'Table',@level1name=N'catMensajesErroresTbl', @level2type=N'Column',@level2name=N'idError'
Go
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción del Mensaje de Error' , @level0type=N'Schema',@level0name=N'dbo', @level1type=N'Table',@level1name=N'catMensajesErroresTbl', @level2type=N'Column',@level2name=N'mensaje'
Go
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del Usuario que Actualizó el Registro' , @level0type=N'Schema',@level0name=N'dbo', @level1type=N'Table',@level1name=N'catMensajesErroresTbl', @level2type=N'Column',@level2name=N'idUsuarioAct'
Go
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última Fecha de  Actualización del Registro' , @level0type=N'Schema',@level0name=N'dbo', @level1type=N'Table',@level1name=N'catMensajesErroresTbl', @level2type=N'Column',@level2name=N'fechaAct'
Go
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección IP desde donde se Actualizó el Registro' , @level0type=N'Schema',@level0name=N'dbo', @level1type=N'Table',@level1name=N'catMensajesErroresTbl', @level2type=N'Column',@level2name=N'ipAct'
Go