Use DB_Siccorp_DES
Go

--
-- Script:      ValidacionComprobantesMigrados
-- Objetivo:    Script de Validación comprobantes contables migrados
-- Fecha:       11/12/2024
-- Programador: Pedro Zambrano.
-- Versión:     1
--

Declare
   @w_idError                 Integer,
   @w_anio                    Integer,
   @w_anioIni                 Integer,
   @w_anioFin                 Integer,
   @w_mesProc                 Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_mesIni                  Tinyint,
   @w_mesFin                  Tinyint,
   @w_secuencia               Integer,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_tabla                   Sysname,
   @w_desc_error              Varchar( 250),
   @w_sql                     Varchar( Max),
   @w_referencia              Varchar( 20),
   @w_impCargo                Decimal(18, 2),
   @w_impAbono                Decimal(18, 2),
   @w_fechaMov                Date,
   @w_inicio                  Bit;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_secuencia = 0,
          @w_inicio    = 1;

   Select @w_anioIni  = Datepart(yyyy, parametroFecha) - 1
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 11;

   Select @w_anioFin = ejercicio
   From   dbo.Control With  (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select  @w_Error      = 9999,
                 @w_desc_error = 'Error: No hay Ejercicios en Estatus 1 en la tabla control.'

         Set Xact_Abort Off
         Return
      End

   Select @w_mesIni = Min(valor),
          @w_mesFin = Max(valor)
   From   dbo.catCriteriosTbl
   Where  criterio = 'mes';

   If Exists ( Select Top 1 1
               From   dbo.MgrComprobantesDiaTbl)
      Begin
         Begin Try
            Truncate table dbo.MgrComprobantesDiaTbl
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)

         End   Catch

         If @w_error != 0
            Begin
               Select @w_error, @w_desc_error;

               Goto Salida
            End

      End
    
   While @w_anioIni < @w_anioFin
   Begin
      Select @w_anioIni = @w_anioIni + 1,
             @w_tabla   = Concat('Poldia', @w_anioIni);

      If Ejercicio_DES.dbo.Fn_existe_tabla(@w_tabla) = 0
         Begin
            Goto Siguiente
         End

      Set @w_sql = Concat('Select Fecha_mov, Referencia, sum(Importe_Cargo), Sum(Importe_Abono) ',
                          'From   Ejercicio_DES.dbo.', @w_tabla, ' a ' ,
                          'Group  By Fecha_mov, Referencia ',
                          'Order  By Fecha_mov, Referencia ')

      Begin Try
         Insert Into dbo.MgrComprobantesDiaTbl
        (fechaMov,  referencia, cargosOri, abonosOri)
         Execute(@w_sql)
         Set @w_registros = @w_registros + @@Rowcount;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If @w_error != 0
         Begin
            Select @w_error, @w_desc_error;

            Select @w_error      = 0,
                   @w_desc_error = '';

            Goto Salida
         End

Siguiente:


   End

   Begin Try
      Update dbo.MgrComprobantesDiaTbl
      Set    difOrigen = cargosOri - abonosOri;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If @w_error != 0
      Begin
         Select @w_error, @w_desc_error;

         Select @w_error      = 0,
                @w_desc_error = '';

         Goto Salida
      End

   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1;
      
      Select @w_fechaMov   = fechaMov,
             @w_referencia = Referencia
      From   dbo.MgrComprobantesDiaTbl
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
         End

      Select @w_anio     = DatePart(yyyy, @w_fechaMov),
             @w_mes      = DatePart(mm,   @w_fechaMov),
             @w_impCargo = 0,
             @w_impAbono = 0;


      Select @w_impCargo = Sum(Importe_Cargo),
             @w_impAbono = Sum(Importe_Abono)
      From   dbo.movimientosAnio With (Nolock)
      Where  Referencia = @w_referencia
      And    Fecha_mov  = @w_fechaMov;
            
      Select @w_impCargo = Isnull(@w_impCargo, 0),
             @w_impAbono = Isnull(@w_impAbono, 0);

      Begin Try

         Update dbo.MgrComprobantesDiaTbl
         Set     cargosMgr  = @w_impCargo,
                 abonosMgr  = @w_impAbono,
                 difMigrada = @w_impCargo - @w_impAbono
         From   dbo.MgrComprobantesDiaTbl
         Where  secuencia = @w_secuencia;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)
   
      End   Catch
   
      If @w_error != 0
         Begin
            Select @w_error, @w_desc_error;
   
            Select @w_error      = 0,
                   @w_desc_error = '';
   
            Goto Salida
         End
      
   End

   Begin Try
      Update dbo.MgrComprobantesDiaTbl
      Set    diferenciaCar = cargosOri - cargosMgr,
             diferenciaAbo = abonosOri - abonosMgr;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If @w_error != 0
      Begin
         Select @w_error, @w_desc_error;

         Select @w_error      = 0,
                @w_desc_error = '';

         Goto Salida
      End

Salida:

   Set Xact_Abort  Off
   Return

End
Go
