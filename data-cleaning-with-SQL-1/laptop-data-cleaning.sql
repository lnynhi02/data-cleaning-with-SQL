1.Remove duplicates
Create the table from the original data
CREATE TABLE laptop_data.laptop_cleaning AS
	SELECT * FROM laptop_data.laptops;

CREATE TABLE laptop_data.cleaning (
  `company` text,
  `type_name` text,
  `inches` double DEFAULT NULL,
  `screen_resolution` text,
  `cpu` text,
  `ram` text,
  `memory` text,
  `gpu` text,
  `op_sys` text,
  `weight` text,
  `price` double DEFAULT NULL,
  `row_number` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO laptop_data.cleaning
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY Company, TypeName, Inches, ScreenResolution, 
							`Cpu`, Ram, `Memory`, Gpu, OpSys, Weight, Price) as row_number
	FROM laptop_data.laptops_cleaning;
    
DELETE FROM laptop_data.cleaning
WHERE (`row_number` > 1);

SELECT * FROM laptop_data.cleaning
WHERE `row_number` > 1;


2. Null Values or Blank Values
SELECT * FROM cleaning
WHERE company IS NULL 
	AND type_name IS NULL
	AND inches IS NULL
    AND screen_resolution IS NULL 
    AND `cpu` IS NULL
	AND ram IS NULL
    AND `memory` IS NULL
    AND gpu IS NULL
    AND op_sys IS NULL
    AND weight IS NULL
    AND price IS NULL;

-> No null values or blank values 


3. Remove any columns
ALTER TABLE cleaning
DROP COLUMN `row_number`;


4. Modify the data

Extract the width and height from screen_resolution column
ALTER TABLE cleaning
	ADD COLUMN resolution_width INT AFTER screen_resolution,
	ADD COLUMN resolution_height INT AFTER screen_resolution;

UPDATE cleaning 
SET resolution_width = substring_index(replace(screen_resolution, ' ', ''), 'x', -1);

UPDATE cleaning 
SET resolution_height = substring_index(substring_index(screen_resolution, ' ', -1), 'x', 1);

If the laptop is a 'touchscreen' device, the is_touchscreen column will be 'Yes' ortherwise 'No'
ALTER TABLE cleaning
	ADD COLUMN is_touchscreen VARCHAR(3) AFTER resolution_width;

UPDATE cleaning
	SET is_touchscreen = CASE WHEN screen_resolution LIKE '%Touchscreen%' THEN 'Yes' ELSE 'No' END;

Delete the 'GB' for easier querying and analysis, and to modify the data type later
UPDATE cleaning
SET ram = replace(ram, 'GB', '');

Just like the screen_resolution column above
We will continue to extract the brand, name and speed from cpu column to other columns
ALTER TABLE cleaning
	ADD COLUMN cpu_brand VARCHAR(25) AFTER `cpu`,
    ADD COLUMN cpu_name VARCHAR(25) AFTER cpu_brand,
    ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

ALTER TABLE cleaning
MODIFY COLUMN cpu_name VARCHAR(50);

UPDATE cleaning
SET cpu_brand = substring_index(`cpu`, ' ', 1);

UPDATE cleaning
SET cpu_speed = replace(substring_index(`cpu`, ' ', -1), 'GHz', '');

UPDATE cleaning
SET cpu_name = replace(replace(`cpu`, cpu_brand, ''), substring_index(`cpu`, ' ', -1), ' ');

Change some values in the op_sys column
UPDATE cleaning
SET op_sys = CASE WHEN op_sys LIKE 'No OS' THEN NULL ELSE op_sys END;

UPDATE cleaning
SET op_sys = CASE when op_sys LIKE 'Mac OS X' THEN 'macOS' ELSE op_sys END; 

Just like above, we will extract the brand and name from gpu
ALTER TABLE cleaning
ADD COLUMN gpu_brand VARCHAR(25) AFTER gpu,
ADD COLUMN gpu_name VARCHAR(50) AFTER gpu_brand;

UPDATE cleaning
SET gpu_brand = substring_index(gpu, ' ', 1);

UPDATE cleaning
SET gpu_name = TRIM(replace(gpu, gpu_brand, ''));

Remove the 'kg', round the value and change the data type of weight column 
UPDATE cleaning
SET weight = replace(weight, 'kg', '');

UPDATE cleaning
SET weight = ROUND(weight, 1);

ALTER TABLE cleaning
MODIFY COLUMN weight DECIMAL(10,1);

Round the price for better looking
UPDATE cleaning
SET price = ROUND(price);


5. Change the data taype if needed
ALTER TABLE cleaning
MODIFY COLUMN company VARCHAR(25);

ALTER TABLE cleaning
MODIFY COLUMN type_name VARCHAR(50);

ALTER TABLE cleaning
MODIFY COLUMN screen_resolution VARCHAR(50);

ALTER TABLE cleaning
MODIFY COLUMN `cpu` VARCHAR(60),
MODIFY COLUMN ram INT,
MODIFY COLUMN `memory` VARCHAR(50),
MODIFY COLUMN gpu VARCHAR(60),
MODIFY COLUMN op_sys VARCHAR(25),
MODIFY COLUMN price INT;

