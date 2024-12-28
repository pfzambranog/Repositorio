
-- Declare
   -- @PnEjercicio       Smallint     = 2024,
   -- @PnMes             Tinyint      = 10,
   -- @PnEstatus         Integer      = 0,
   -- @PsMensaje         Varchar(250) = Null;
-- Begin
   -- Execute dbo.Spp_recalculoNivelCatalogo @PnEjercicio = @PnEjercicio,
                                          -- @PnMes       = @PnMes, 
                                          -- @PnEstatus   = @PnEstatus  Output,
                                          -- @PsMensaje   = @PsMensaje  Output;

   -- Select @PnEstatus IdError, @PsMensaje MensajeError;
   -- Return
-- End
-- Go
   
--
-- Objetivo:    Recalculo de los niveles contables en la tabla catalogo.
--
-- Fecha:       28-dic-2024.
-- Programdor:  Pedro Zambrano
-- Version:     1
--

Create Or Alter Procedure Spp_recalculoNivelCatalogo
  (@PnEjercicio               Smallint,
   @PnMes                     Tinyint,
   @PnEstatus                 Integer      = 0 Output,
   @PsMensaje                 Varchar(250) = Null Output)
As

Declare
   @w_error                   Integer,
   @w_registros               Integer,
   @w_secuencia               Integer,
   @w_linea                   Integer,
   @w_Niv                     Smallint,
   @w_desc_error              Varchar(250),
   @w_Descrip                 Varchar(100),
   @w_llave                   Varchar( 20),
   @w_SSSubCta                Varchar( 20),
   @w_SSubCta                 Varchar( 20),
   @w_SubCta                  Varchar( 20),
   @w_CtaMayor                Varchar( 20),
   @w_moneda                  Varchar(  2),
   @w_ceros                   Varchar( 20),
   @w_Sant                    Decimal(18, 2),
   @w_Car                     Decimal(18, 2),
   @w_Abo                     Decimal(18, 2),
   @w_CarProceso              Decimal(18, 2),
   @w_AboProceso              Decimal(18, 2);

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_registros = 0,
          @w_secuencia = 0,
          @w_Niv       = 0,
          @PnEstatus   = 0,
          @w_moneda    = '01',
          @w_ceros     = Replicate('0', 20),
          @PsMensaje   = Char(32);

--
-- Generacion de Tabla temporal
--

   Create Table #TempNivCatalogo
  (secuencia   Integer  Not Null Identity (1, 1) Primary Key,
   Llave        Varchar(20)    Not Null,
   Moneda       Varchar( 2)    Not Null,
   Niv          Smallint       Not Null,
   Descrip      Varchar(100)   Not Null,
   Sant         Decimal(18, 2) Not Null Default 0,
   Car          Decimal(18, 2) Not Null,
   Abo          Decimal(18, 2) Not Null,
   CarProceso   Decimal(18, 2) Not Null,
   AboProceso   Decimal(18, 2) Not Null,
   Ejercicio    Smallint       Not Null,
   mes          Tinyint        Not Null,
   Index TempCatalogoIdx01 Unique (llave, moneda, ejercicio, mes, Niv));

--
-- Inicio de Proceso
--

   Begin Try
      Insert Into #TempNivCatalogo
     (Llave,     Moneda, Niv,        Sant,
      Car,       Abo,    CarProceso, AboProceso,
      Ejercicio, mes,    Descrip)
      Select Llave,     Moneda, Niv,        Sant,
             Car,       Abo,    CarProceso, AboProceso,
             Ejercicio, mes,    descrip
      From   dbo.Catalogo With (Nolock)
      Where  Ejercicio    = @PnEjercicio
      And    mes          = @PnMes
      And    Niv          = 1;
      Set @w_registros = @@Rowcount;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End Catch

   If IsNull(@w_error, 0) <> 0
      Begin

         Select @PnEstatus = @w_error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

         Goto Salida
      End

   If @w_registros = 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

         Goto Salida
      End

   Begin Transaction
      Begin Try
         Delete dbo.Catalogo
         Where  Ejercicio    = @PnEjercicio
         And    mes          = @PnMes
         And    Niv         != 1;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction
            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Goto Salida
         End


      While @w_secuencia < @w_registros
      Begin
         Set @w_secuencia = @w_secuencia + 1;

         Select @w_llave      = llave,
                @w_moneda     = moneda,
                @w_Sant       = Sant,
                @w_Car        = Car,
                @w_Abo        = Abo,
                @w_CarProceso = CarProceso,
                @w_AboProceso = AboProceso
         From   #TempNivCatalogo
         Where  secuencia = @w_secuencia;
         If @@Rowcount = 0
            Begin
               Break
            End

         Select @w_SSSubCta = Concat(Left(@w_llave,10), Right(@w_ceros,  6)), -- Variable que identifica la SSSubCta
                @w_SSubCta  = Concat(Left(@w_llave, 8), Right(@w_ceros,  8)), -- Variable que identifica la SSubCta
                @w_SubCta   = Concat(Left(@w_llave, 6), Right(@w_ceros, 10)), -- Variable que identifica la SubCta
                @w_CtaMayor = Concat(Left(@w_llave, 4), Right(@w_ceros, 12)); -- Variable que identifica la Cta Mayor

--
-- Actualiza la SSSubCta
--

         Begin Try
            Update dbo.catalogo
            Set    Sant       = Sant       + @w_Sant,
                   Car        = Car        + @w_Car,
                   Abo        = Abo        + @w_Abo,
                   CarProceso = CarProceso + @w_CarProceso,
                   AboProceso = AboProceso + @w_AboProceso
            Where  ejercicio = @PnEjercicio
            And    mes       = @PnMes
            And    llave     = @w_SSSubCta
            And    Niv       = @w_niv;
            If @@Rowcount = 0
               Begin
                  Insert Into dbo.catalogo
                 (Llave,     Moneda,  Niv,   Descrip,    SAnt,
                  Car,       Abo,     SAct,  CarProceso, AboProceso,
                  Ejercicio, Mes)
                  Select Top 1 @w_SSSubCta,  @w_Moneda, @w_niv, b.descripcion,  @w_Sant,
                               @w_Car,       @w_Car,    0,      @w_CarProceso,  @w_AboProceso,
                               @PnEjercicio, @PnMes
                  From   dbo.catalogoConsolidado b With (Nolock)
                  Where  numerodecuenta = @w_SSSubCta;
               End

--
-- Actualiza la SSubCta
--

            Update dbo.catalogo
            Set    Sant       = Sant       + @w_Sant,
                   Car        = Car        + @w_Car,
                   Abo        = Abo        + @w_Abo,
                   CarProceso = CarProceso + @w_CarProceso,
                   AboProceso = AboProceso + @w_AboProceso
            Where  ejercicio = @PnEjercicio
            And    mes       = @PnMes
            And    llave     = @w_SSubCta
            And    Niv       = @w_niv;
            If @@Rowcount = 0
               Begin
                  Insert Into dbo.catalogo
                 (Llave,     Moneda,  Niv,   Descrip,    SAnt,
                  Car,       Abo,     SAct,  CarProceso, AboProceso,
                  Ejercicio, Mes)
                  Select Top 1 @w_SSubCta,   @w_Moneda, @w_niv, b.descripcion,  @w_Sant,
                               @w_Car,       @w_Car,    0,      @w_CarProceso,  @w_AboProceso,
                               @PnEjercicio, @PnMes
                  From   dbo.catalogoConsolidado b With (Nolock)
                  Where  numerodecuenta = @w_SSubCta;
               End

--
-- Actualiza la SubCta
--

            Update dbo.catalogo
            Set    Sant       = Sant       + @w_Sant,
                   Car        = Car        + @w_Car,
                   Abo        = Abo        + @w_Abo,
                   CarProceso = CarProceso + @w_CarProceso,
                   AboProceso = AboProceso + @w_AboProceso
            Where  ejercicio = @PnEjercicio
            And    mes       = @PnMes
            And    llave     = @w_SubCta
            And    Niv       = @w_niv;
            If @@Rowcount = 0
               Begin
                  Insert Into dbo.catalogo
                 (Llave,     Moneda,  Niv,   Descrip,    SAnt,
                  Car,       Abo,     SAct,  CarProceso, AboProceso,
                  Ejercicio, Mes)
                  Select Top 1 @w_SubCta,   @w_Moneda, @w_niv, b.descripcion,  @w_Sant,
                               @w_Car,       @w_Car,    0,      @w_CarProceso,  @w_AboProceso,
                               @PnEjercicio, @PnMes
                  From   dbo.catalogoConsolidado b With (Nolock)
                  Where  numerodecuenta = @w_SubCta;
               End

--
-- Actualiza la Cuenta Mayor
--

            Update dbo.catalogo
            Set    Sant       = Sant       + @w_Sant,
                   Car        = Car        + @w_Car,
                   Abo        = Abo        + @w_Abo,
                   CarProceso = CarProceso + @w_CarProceso,
                   AboProceso = AboProceso + @w_AboProceso
            Where  ejercicio = @PnEjercicio
            And    mes       = @PnMes
            And    llave     = @w_CtaMayor
            And    Niv       = @w_niv;
            If @@Rowcount = 0
               Begin
                  Insert Into dbo.catalogo
                 (Llave,     Moneda,  Niv,   Descrip,    SAnt,
                  Car,       Abo,     SAct,  CarProceso, AboProceso,
                  Ejercicio, Mes)
                  Select Top 1 @w_CtaMayor,   @w_Moneda, @w_niv, b.descripcion,  @w_Sant,
                               @w_Car,       @w_Car,    0,      @w_CarProceso,  @w_AboProceso,
                               @PnEjercicio, @PnMes
                  From   dbo.catalogoConsolidado b With (Nolock)
                  Where  numerodecuenta = @w_CtaMayor;
               End

         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)
         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Rollback Transaction

               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Goto Salida
            End

      End;

   Commit Transaction

Salida:

   If @PnEstatus = 0
      Begin
         Set @PsMensaje = 'Proceso Terminado Ok'
      End


   Set Xact_Abort    On
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Recalcula los niveles contables en la tabla catalogo.',
   @w_procedimiento  Varchar( 100) = 'Spp_recalculoNivelCatalogo'


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
                                      @level0name = N'Dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento;

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'Dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go