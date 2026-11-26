# Creamos el archivo solucion.sql
 USE employees_db;
 
#-------------------------------------------------------------------------------------------------------------

# Ejercicio 1

# Creamos el procedmiento p_end_contract
# Ponga la fecha de fin del contrato de un empleado y asigne sus subordinados activos a su jefe.
# Debe rechazar empleados que ya hayan terminado y deshacer todos los cambios si alguno falla

DELIMITER //

CREATE OR REPLACE PROCEDURE p_end_contract(p_employee_id INT, p_end_date DATE)
BEGIN
    DECLARE v_jefe INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_end_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hay que establecer una fecha de fin de contrato';
    END IF;

    # Establecemos la fecha de fin del contrato del empleado
    UPDATE employees SET end_date = p_end_date WHERE employee_id = p_employee_id AND end_date > CURRENT_DATE;

	 # Para saber si el empleado no está entre los empleados, si no se ha modificado ninguna fila, entonces la condición del WHERE no se ha cumplido
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe este empleado en la base de datos, o ya no está trabajando como empleado';
    END IF;

    # Guardamos el jefe en la variable v_jefe
    SELECT boss_id INTO v_jefe FROM employees WHERE employee_id = p_employee_id;

    # Ahora por último les cambiamos el jefe a sus subordinados para que sea el nuevo jefe
    UPDATE employees SET boss_id = v_jefe WHERE boss_id = p_employee_id;

    COMMIT;
END //

DELIMITER ;

# Ahora creamos la función f_num_subordinates
# Devuelve el número de subordinados activos de un empleado

DELIMITER //

CREATE OR REPLACE FUNCTION f_num_subordinates(p_employee_id INT)
RETURNS INT
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*) INTO v_total
    FROM employees
    WHERE boss_id = p_employee_id;

    RETURN v_total;
END //

DELIMITER ;

