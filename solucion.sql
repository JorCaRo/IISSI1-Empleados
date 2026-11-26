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
    UPDATE employees SET end_date = p_end_date WHERE employee_id = p_employee_id AND (end_date > CURRENT_DATE OR end_date IS NULL);

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
    DECLARE v_res INT;

    SELECT COUNT(*) INTO v_res FROM employees WHERE boss_id = p_employee_id;

    RETURN v_res;
END //

DELIMITER ;

# Ahora testeamos con la prueba

CALL p_populate();

# Pedro (1) tiene tres subordinados (Luis, Ana y Daniel), pero solo Daniel está activo
SELECT f_num_subordinates(1);
CALL p_end_contract(1, '2026-12-31');

# Pedro tiene fecha de fin y Daniel pasa a su jefe (Pedro no tiene: queda sin jefe)
SELECT * FROM employees;
SELECT f_num_subordinates(1);

# Deben fallar
CALL p_end_contract(4, '2026-12-31'); # Luis ya terminó
CALL p_end_contract(99, '2026-12-31'); # No existe
