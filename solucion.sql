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
    
END //

DELIMITER ;