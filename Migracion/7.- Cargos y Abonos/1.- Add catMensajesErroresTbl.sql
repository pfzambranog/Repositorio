Declare
   @w_idFormulario   Integer       = 9999,
   @w_idError        Integer       = 8161,
   @w_idUsuarioAct   Integer       = 1,
   @w_fechaAct       Smalldatetime = GetDate(),
   @w_ipAct          Varchar( 30)  = dbo.Fn_BuscaDireccionIP(),
   @w_mensaje        Varchar(250)  = 'Fecha Inicial es Mayor a la Fecha Final';

Begin
   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8162,
          @w_mensaje        = 'Fecha Inicial y la Fecha Final no estan en el mismo período';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8160,
          @w_mensaje        = 'Fecha Inicial y la Fecha Final no Pueden ser Nulo';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8163,
          @w_mensaje        = 'La suma de las Pólizas de esta fecha de captura está descuadrada. Por favor verifique Cargos y Abonos';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8164,
          @w_mensaje        = 'La suma de las Pólizas de esta fecha de captura están cuadradas.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8165,
          @w_mensaje        = 'Existen Pólizas Descuadradas en el Período.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End


   Select @w_idError        = 8166,
          @w_mensaje        = 'No Existen Pólizas Descuadradas en el Período.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End


   Select @w_idError        = 8167,
          @w_mensaje        = 'No existen Pólizas con errores en el Período.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End


   Select @w_idError        = 8168,
          @w_mensaje        = 'Existen Pólizas con errores en el Período.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8169,
          @w_mensaje        = 'El parametro de Referencia de Póliza y fecha de la Póliza son Obligatorio.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8170,
          @w_mensaje        = 'La Póliza seleccionada no es Válida.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8171,
          @w_mensaje        = 'El parámetro de tipo de consulta no es válido.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End

   Select @w_idError        = 8172,
          @w_mensaje        = 'No existen Datos para los registros seleccionados.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8021,
          @w_mensaje        = 'El ejercicio seleccionado no es válido.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8022,
          @w_mensaje        = 'El ejercicio seleccionado no está disponible.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8023,
          @w_mensaje        = 'El mes seleccionado no es válido.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8024,
          @w_mensaje        = 'El ejercicio y mes seleccionado no es válido.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8025,
          @w_mensaje        = 'El ejercicio y mes seleccionado no está habilitado.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8026,
          @w_mensaje        = 'No Existen Datos del ejercicio y mes seleccionado.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;


   Select @w_idError        = 8027,
          @w_mensaje        = 'El mes a procesar no es el último del período.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8028,
          @w_mensaje        = 'La Póliza Seleccionada esta descuadrada';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8029,
          @w_mensaje        = 'La cuenta de resultado no esta relacionada al catálogo de cuentas.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8030,
          @w_mensaje        = 'Existen Sucursales sin La cuenta de resultado relacionada.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Select @w_idError        = 8031,
          @w_mensaje        = 'El mes a procesar no es el último mes del período.';

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idFormulario = @w_idFormulario
                   And    idError      = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idFormulario, idError, mensaje, idUsuarioAct,
          fechaAct,     ipAct)
         Select @w_idFormulario, @w_idError, @w_mensaje, @w_idUsuarioAct,
                @w_fechaAct,     @w_ipAct;
      End
   Else
      Begin
         Update dbo.catMensajesErroresTbl
         Set    mensaje      = @w_mensaje,
                idUsuarioAct = @w_idUsuarioAct,
                fechaAct     = @w_fechaAct,
                ipAct        = @w_ipAct
         Where  idFormulario = @w_idFormulario
         And    idError      = @w_idError;
      End;

   Return;

End;
Go
