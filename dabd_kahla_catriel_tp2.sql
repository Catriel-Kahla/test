-- Sección 1: Procedimientos almacenados y bloque PL SQL

-- Procedimiento para registrar un pedido y su detalle
DECLARE
    v_stock_actual productos.stock%TYPE;
    v_total_renglon detallePedidos.total%TYPE;
BEGIN
    -- Iniciar la transacción
    SAVEPOINT inicio_transaccion;
    
    -- Registro del pedido
    INSERT INTO pedidos (NumeroPedido, idcliente, idvendedor, fecha, estado)
    VALUES (seq_numeroPedido.NEXTVAL, :cliente_id, :vendedor_id, SYSDATE, 'CONFIRMADO');

    -- Procesar cada detalle del pedido
    FOR renglon IN 1..:total_renglones LOOP
        -- Verificar si hay stock suficiente para el producto
        SELECT stock INTO v_stock_actual
        FROM productos
        WHERE idproducto = :producto_id(renglon);
        
        IF v_stock_actual < :cantidad(renglon) THEN
            ROLLBACK TO inicio_transaccion;
            RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente para el producto: ' || :producto_id(renglon));
        ELSE
            -- Actualizar stock
            UPDATE productos
            SET stock = stock - :cantidad(renglon)
            WHERE idproducto = :producto_id(renglon);
            
            -- Insertar el detalle del pedido
            v_total_renglon := :cantidad(renglon) * :precio_unitario(renglon);
            INSERT INTO detallePedidos (NumeroPedido, renglon, idproducto, cantidad, PrecioUnitario, Total)
            VALUES (seq_numeroPedido.CURRVAL, renglon, :producto_id(renglon), :cantidad(renglon), :precio_unitario(renglon), v_total_renglon);
        END IF;
    END LOOP;

    -- Confirmar la transacción
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, deshacer la transacción
        ROLLBACK;
        RAISE;
END;

-- Procedimiento para anular un pedido confirmado
CREATE OR REPLACE PROCEDURE anular_pedido(p_numeroPedido IN NUMBER) AS
BEGIN
    -- Actualizar el estado del pedido
    UPDATE pedidos
    SET estado = 'ANULADO'
    WHERE NumeroPedido = p_numeroPedido;
    
    -- Devolver el stock de los productos
    FOR detalle IN (SELECT idproducto, cantidad FROM detallePedidos WHERE NumeroPedido = p_numeroPedido) LOOP
        UPDATE productos
        SET stock = stock + detalle.cantidad
        WHERE idproducto = detalle.idproducto;
    END LOOP;
    
    -- Llamar al trigger para registrar en el log
    COMMIT;
END;

-- Procedimiento para actualizar el precio de los artículos de un origen
CREATE OR REPLACE PROCEDURE actualizar_precio(origen_producto IN VARCHAR2, porcentaje_aumento IN NUMBER) AS
BEGIN
    -- Actualizar precios según el origen
    UPDATE productos
    SET PrecioUnitario = PrecioUnitario * (1 + porcentaje_aumento / 100)
    WHERE origen = origen_producto;

    COMMIT;
END;


-- Sección 2: Triggers

-- Creación del trigger para registrar la anulación de un pedido en la tabla log
CREATE OR REPLACE TRIGGER log_anulacion_pedido
AFTER UPDATE OF estado ON pedidos
FOR EACH ROW
WHEN (NEW.estado = 'ANULADO')
BEGIN
    INSERT INTO log (idlog, numeroPedido, FechaAnulacion)
    VALUES (seq_log.NEXTVAL, :NEW.NumeroPedido, SYSDATE);
END;


-- Sección 3: Creación de tablas

-- Creación de la tabla log para registrar los pedidos anulados
CREATE TABLE log (
    idlog NUMBER PRIMARY KEY,
    numeroPedido NUMBER NOT NULL,
    FechaAnulacion DATE NOT NULL
);

