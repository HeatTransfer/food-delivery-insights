# One-time or periodic batch update for consistent values
WITH cte AS (
    SELECT order_id, SUM(quantity * price) AS total
    FROM order_item
    GROUP BY order_id
)
UPDATE orders o
JOIN cte c ON o.order_id = c.order_id
SET o.amount = c.total;

# ================= helps to auto-update or auto-populate amount column in orders table ====================
DELIMITER //

CREATE TRIGGER update_order_amount
AFTER INSERT ON order_item
FOR EACH ROW
BEGIN
  UPDATE orders
  SET amount = (
    SELECT SUM(quantity * price)
    FROM order_item
    WHERE order_id = NEW.order_id
  )
  WHERE order_id = NEW.order_id;
END;
//

DELIMITER ;
