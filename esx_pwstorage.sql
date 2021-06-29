USE `es_extended`;

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