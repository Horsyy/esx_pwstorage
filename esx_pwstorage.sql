USE `es_extended`;

CREATE TABLE `esx_pwstorage` (
	`password` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`society` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`expired` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
);

INSERT INTO `esx_pwstorage` (password, society, expired) VALUES
	-- First Example
	('1314', 'society_HorseStorage', '2021-07-10'),
	-- Second Example
	('1315', 'society_ShokaStorage', '2021-07-10')
;

INSERT INTO `addon_account` (name, label, shared) VALUES
	-- First Example
	('society_HorseStorage', 'Horse Storage', 1),
	('society_HorseStorage_blackMoney', 'Horse Storage Black Money', 1),
	-- Second Example
	('society_ShokaStorage', 'Shoka Storage', 1),
	('society_ShokaStorage_blackMoney', 'Shoka Storage Black Money', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	-- First Example
	('society_HorseStorage', 'Horse Storage', 1),
	-- Second Example
	('society_ShokaStorage', 'Shoka Storage', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	-- First Example
	('society_HorseStorage', 'Horse Storage', 1),
	-- Second Example
	('society_ShokaStorage', 'Shoka Storage', 1)
;
