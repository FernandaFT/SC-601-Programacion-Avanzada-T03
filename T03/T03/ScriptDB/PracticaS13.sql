USE [master]
GO

CREATE DATABASE [PracticaS13]
GO
USE [PracticaS13]
GO

CREATE TABLE [dbo].[Abonos](
	[Id_Compra] [bigint] NOT NULL,
	[Id_Abono] [bigint] IDENTITY(1,1) NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
	[Fecha] [datetime] NOT NULL,
 CONSTRAINT [PK_Abonos] PRIMARY KEY CLUSTERED 
(
	[Id_Abono] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[Principal](
	[Id_Compra] [bigint] IDENTITY(1,1) NOT NULL,
	[Precio] [decimal](18, 5) NOT NULL,
	[Saldo] [decimal](18, 5) NOT NULL,
	[Descripcion] [varchar](500) NOT NULL,
	[Estado] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Principal] PRIMARY KEY CLUSTERED 
(
	[Id_Compra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Abonos] ON 
GO
INSERT [dbo].[Abonos] ([Id_Compra], [Id_Abono], [Monto], [Fecha]) VALUES (5, 1, CAST(80.00 AS Decimal(18, 2)), CAST(N'2026-04-10T09:10:56.600' AS DateTime))
GO
INSERT [dbo].[Abonos] ([Id_Compra], [Id_Abono], [Monto], [Fecha]) VALUES (5, 2, CAST(400.00 AS Decimal(18, 2)), CAST(N'2026-04-10T09:11:07.633' AS DateTime))
GO
INSERT [dbo].[Abonos] ([Id_Compra], [Id_Abono], [Monto], [Fecha]) VALUES (2, 3, CAST(500.00 AS Decimal(18, 2)), CAST(N'2026-04-10T09:22:09.430' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Abonos] OFF
GO
SET IDENTITY_INSERT [dbo].[Principal] ON 
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (1, CAST(50000.00000 AS Decimal(18, 5)), CAST(50000.00000 AS Decimal(18, 5)), N'Producto 1', N'Pendiente')
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (2, CAST(13500.00000 AS Decimal(18, 5)), CAST(13000.00000 AS Decimal(18, 5)), N'Producto 2', N'Pendiente')
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (3, CAST(83600.00000 AS Decimal(18, 5)), CAST(83600.00000 AS Decimal(18, 5)), N'Producto 3', N'Pendiente')
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (4, CAST(1220.00000 AS Decimal(18, 5)), CAST(1220.00000 AS Decimal(18, 5)), N'Producto 4', N'Pendiente')
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (5, CAST(480.00000 AS Decimal(18, 5)), CAST(0.00000 AS Decimal(18, 5)), N'Producto 5', N'Cancelado')
GO
SET IDENTITY_INSERT [dbo].[Principal] OFF
GO
ALTER TABLE [dbo].[Abonos]  WITH CHECK ADD  CONSTRAINT [FK_Abonos_Principal] FOREIGN KEY([Id_Compra])
REFERENCES [dbo].[Principal] ([Id_Compra])
GO
ALTER TABLE [dbo].[Abonos] CHECK CONSTRAINT [FK_Abonos_Principal]

GO
CREATE PROCEDURE [dbo].[sp_ConsultarCompras]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id_Compra,
        Descripcion,
        Precio,
        Saldo,
        Estado
    FROM Principal
    ORDER BY 
        CASE WHEN Estado = 'Pendiente' THEN 0 ELSE 1 END
END

GO
CREATE   PROCEDURE [dbo].[sp_ConsultarComprasPendientes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id_Compra, Descripcion, CAST(Saldo AS DECIMAL(18,2)) AS Saldo
    FROM dbo.Principal
    WHERE Estado = 'Pendiente'
    ORDER BY Id_Compra ASC;
END;

GO
CREATE   PROCEDURE [dbo].[sp_ConsultarSaldo]
    @vId_Compra BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CAST(Saldo AS DECIMAL(18,2)) AS Saldo
    FROM dbo.Principal
    WHERE Id_Compra = @vId_Compra;
END;

GO
CREATE   PROCEDURE [dbo].[sp_PagoParcial]
    @vId_Compra BIGINT,
    @vMonto DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @vSaldoActual DECIMAL(18,2);

    BEGIN TRY
        BEGIN TRAN;
        SELECT @vSaldoActual = CAST(Saldo AS DECIMAL(18,2))
        FROM dbo.Principal WITH (UPDLOCK, ROWLOCK)
        WHERE Id_Compra = @vId_Compra
          AND Estado = 'Pendiente';

        IF @vSaldoActual IS NULL
        BEGIN
            RAISERROR('La compra no existe o no está pendiente.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END

        IF @vMonto <= 0
        BEGIN
            RAISERROR('El monto del abono debe ser mayor que cero.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END

        IF @vMonto > @vSaldoActual
        BEGIN
            RAISERROR('El abono no puede ser mayor al saldo actual.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END

        INSERT INTO dbo.Abonos (Id_Compra, Monto, Fecha)
        VALUES (@vId_Compra, @vMonto, GETDATE());

        UPDATE dbo.Principal
        SET Saldo = Saldo - @vMonto,
            Estado = CASE 
                        WHEN (Saldo - @vMonto) = 0 THEN 'Cancelado'
                        ELSE Estado
                     END
        WHERE Id_Compra = @vId_Compra;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH
END;
GO
USE [master]
GO
ALTER DATABASE [PracticaS13] SET  READ_WRITE 
GO
