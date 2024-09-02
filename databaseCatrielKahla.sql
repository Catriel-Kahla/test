-- 1. Crear la base de datos
CREATE DATABASE PEDIDOS;
USE PEDIDOS;

-- 2. Crear las tablas del modelo de datos

-- Tabla Clientes
CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    apellido VARCHAR(50) NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    dni VARCHAR(20) UNIQUE NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL,
    CONSTRAINT chk_email CHECK (correo_electronico LIKE '%_@__%.__%')
);

-- Tabla Proveedores
CREATE TABLE Proveedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreProveedor VARCHAR(100) NOT NULL,
    telefono BIGINT(11),
    direccion VARCHAR(100)
);

-- Tabla Vendedores
CREATE TABLE Vendedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    apellido VARCHAR(50) NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    dni VARCHAR(20) UNIQUE NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL,
    CONSTRAINT chk_email CHECK (correo_electronico LIKE '%_@__%.__%')
);

-- Tabla Productos
CREATE TABLE Productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    proveedor_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(id)
);

-- Tabla Pedidos
CREATE TABLE Pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    vendedor_id INT,
    fecha DATE NOT NULL,
    total DECIMAL(10, 2),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id),
    FOREIGN KEY (vendedor_id) REFERENCES Vendedores(id)
);

-- Tabla DetallePedidos
CREATE TABLE DetallePedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES Productos(id)
);

-- 3. Poblar la base de datos con datos de ejemplo

-- Insertar clientes
INSERT INTO Clientes (apellido, nombres, dni, correo_electronico)
VALUES 
('Gomez', 'Juan', '12345678', 'juan.gomez@example.com'),
('Perez', 'Ana', '87654321', 'ana.perez@example.com'),
('Lopez', 'Luis', '23456789', 'luis.lopez@example.com'),
('Diaz', 'Maria', '34567890', 'maria.diaz@example.com'),
('Fernandez', 'Carlos', '45678901', 'carlos.fernandez@example.com');

-- Insertar proveedores
INSERT INTO Proveedores (nombreProveedor, telefono, direccion)
VALUES 
('Proveedor A', 123456789, 'Calle Falsa 123'),
('Proveedor B', 987654321, 'Avenida Siempre Viva 742'),
('Proveedor C', 123987456, 'Boulevard de los Sueños 456');

-- Insertar vendedores
INSERT INTO Vendedores (apellido, nombres, dni, correo_electronico)
VALUES 
('Sanchez', 'Gabriel', '56789012', 'gabriel.sanchez@example.com'),
('Garcia', 'Laura', '67890123', 'laura.garcia@example.com'),
('Rodriguez', 'Pablo', '78901234', 'pablo.rodriguez@example.com');

-- Insertar productos
INSERT INTO Productos (descripcion, precio, stock, proveedor_id)
VALUES 
('Producto 1', 100.00, 50, 1),
('Producto 2', 200.00, 30, 1),
('Producto 3', 150.00, 40, 2),
('Producto 4', 250.00, 20, 2),
('Producto 5', 300.00, 10, 3),
('Producto 6', 350.00, 15, 3),
('Producto 7', 400.00, 5, 1),
('Producto 8', 450.00, 8, 2),
('Producto 9', 500.00, 12, 3),
('Producto 10', 550.00, 7, 1);

-- Insertar pedidos
INSERT INTO Pedidos (cliente_id, vendedor_id, fecha, total)
VALUES 
(1, 1, '2024-08-01', 350.00),
(2, 2, '2024-08-02', 550.00),
(3, 3, '2024-08-03', 250.00),
(4, 1, '2024-08-04', 500.00),
(5, 2, '2024-08-05', 700.00),
(1, 3, '2024-08-06', 400.00),
(2, 1, '2024-08-07', 150.00),
(3, 2, '2024-08-08', 650.00),
(4, 3, '2024-08-09', 300.00),
(5, 1, '2024-08-10', 800.00);

-- Insertar detalle de pedidos
INSERT INTO DetallePedidos (pedido_id, producto_id, cantidad, precio)
VALUES 
(1, 1, 2, 100.00),
(1, 3, 1, 150.00),
(2, 2, 2, 200.00),
(2, 4, 1, 250.00),
(3, 5, 1, 300.00),
(4, 6, 2, 350.00),
(5, 7, 2, 400.00),
(6, 8, 1, 450.00),
(7, 9, 1, 500.00),
(8, 10, 1, 550.00);

-- 4. Consultas sobre la base de datos

-- a. Detalle de clientes que realizaron pedidos entre fechas
SELECT c.apellido, c.nombres, c.dni, c.correo_electronico
FROM Clientes c
JOIN Pedidos p ON c.id = p.cliente_id
WHERE p.fecha BETWEEN '2024-08-01' AND '2024-08-10';

-- b. Detalle de vendedores con la cantidad de pedidos realizados
SELECT v.apellido, v.nombres, v.dni, v.correo_electronico, COUNT(p.id) AS CantidadPedidos
FROM Vendedores v
JOIN Pedidos p ON v.id = p.vendedor_id
GROUP BY v.apellido, v.nombres, v.dni, v.correo_electronico;

-- c. Detalle de pedidos con un total mayor a un determinado valor umbral
SELECT id AS NumeroPedido, fecha, total AS TotalPedido
FROM Pedidos
WHERE total > 500.00;

-- d. Lista de productos vendidos entre fechas
SELECT pr.descripcion, SUM(dp.cantidad) AS CantidadTotal
FROM Productos pr
JOIN DetallePedidos dp ON pr.id = dp.producto_id
JOIN Pedidos p ON dp.pedido_id = p.id
WHERE p.fecha BETWEEN '2024-08-01' AND '2024-08-10'
GROUP BY pr.descripcion;

-- e. Proveedor que realizó más ventas
SELECT pr.nombreProveedor, COUNT(dp.id) AS CantidadVentas
FROM Proveedores pr
JOIN Productos p ON pr.id = p.proveedor_id
JOIN DetallePedidos dp ON p.id = dp.producto_id
GROUP BY pr.nombreProveedor
ORDER BY CantidadVentas DESC
LIMIT 1;

-- f. Detalle de clientes registrados que nunca realizaron un pedido
SELECT c.apellido, c.nombres, c.correo_electronico
FROM Clientes c
LEFT JOIN Pedidos p ON c.id = p.cliente_id
WHERE p.id IS NULL;

-- g. Detalle de clientes que realizaron menos de dos pedidos
SELECT c.apellido, c.nombres, c.correo_electronico
FROM Clientes c
JOIN Pedidos p ON c.id = p.cliente_id
GROUP BY c.apellido, c.nombres, c.correo_electronico
HAVING COUNT(p.id) < 2;

-- h. Cantidad total vendida por origen de producto
SELECT pr.nombreProveedor, SUM(dp.cantidad) AS CantidadTotalVendida
FROM Proveedores pr
JOIN Productos p ON pr.id = p.proveedor_id
JOIN DetallePedidos dp ON p.id = dp.producto_id
GROUP BY pr.nombreProveedor;
