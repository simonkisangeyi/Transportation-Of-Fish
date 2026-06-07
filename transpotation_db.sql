-- Database schema and seed data for the Mwanza Fresh Fish transportation project
-- Import this file into MySQL / MariaDB using phpMyAdmin or the MySQL command line.

CREATE DATABASE IF NOT EXISTS `transportation_of_fish`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `transportation_of_fish`;

DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `fish_types`;
DROP TABLE IF EXISTS `destinations`;
DROP TABLE IF EXISTS `customers`;

CREATE TABLE `customers` (
  `customer_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `fullname` VARCHAR(120) NOT NULL,
  `phone` VARCHAR(32) NOT NULL,
  `email` VARCHAR(180) DEFAULT NULL,
  `region` VARCHAR(80) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `idx_customers_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fish_types` (
  `fish_type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `average_price_tzs` INT UNSIGNED NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`fish_type_id`),
  UNIQUE KEY `idx_fish_types_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `destinations` (
  `destination_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(140) NOT NULL,
  `region` VARCHAR(80) DEFAULT NULL,
  `distance_km` INT UNSIGNED DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`destination_id`),
  UNIQUE KEY `idx_destinations_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `orders` (
  `order_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `fish_type_id` INT UNSIGNED NOT NULL,
  `destination_id` INT UNSIGNED NOT NULL,
  `weight_kg` INT UNSIGNED NOT NULL,
  `delivery_date` DATE NOT NULL,
  `instructions` TEXT DEFAULT NULL,
  `status` ENUM('Pending','Scheduled','In Transit','Delivered','Canceled') NOT NULL DEFAULT 'Pending',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  KEY `idx_orders_customer` (`customer_id`),
  KEY `idx_orders_fish` (`fish_type_id`),
  KEY `idx_orders_destination` (`destination_id`),
  CONSTRAINT `fk_orders_customers` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_fish_types` FOREIGN KEY (`fish_type_id`) REFERENCES `fish_types` (`fish_type_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_destinations` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`destination_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `customers` (`fullname`, `phone`, `email`, `region`) VALUES
('Amina Selemani','0712345678','amina.selemani@example.com','Mwanza'),
('David Kato','0712345679','david.kato@example.com','Dar es Salaam'),
('Grace Mwakyoma','0712345680','grace.mwakyoma@example.com','Arusha'),
('John Peter','0712345681','john.peter@example.com','Dodoma'),
('Fatima Hassan','0712345682','fatima.hassan@example.com','Mbeya'),
('Michael Mtui','0712345683','michael.mtui@example.com','Mwanza'),
('Patricia Joseph','0712345684','patricia.joseph@example.com','Tanga'),
('Robert Maseke','0712345685','robert.maseke@example.com','Kilimanjaro'),
('Hannah Chacha','0712345686','hannah.chacha@example.com','Morogoro'),
('Samuel Sanga','0712345687','samuel.sanga@example.com','Iringa'),
('Lilian Mtei','0712345688','lilian.mtei@example.com','Kigoma'),
('Felix Mwasa','0712345689','felix.mwasa@example.com','Tabora'),
('Diana Lyimo','0712345690','diana.lyimo@example.com','Moshi'),
('Emmanuel Nyerere','0712345691','emmanuel.nyerere@example.com','Songea'),
('Rashid Omar','0712345692','rashid.omar@example.com','Lindi'),
('Susan Kajuna','0712345693','susan.kajuna@example.com','Dodoma'),
('Victor Mushi','0712345694','victor.mushi@example.com','Singida'),
('Emily Kessy','0712345695','emily.kessy@example.com','Sumbawanga'),
('Issa Mghalu','0712345696','issa.mghalu@example.com','Musoma'),
('Nancy Rajabu','0712345697','nancy.rajabu@example.com','Kagera'),
('Paulina Nsumba','0712345698','paulina.nsumba@example.com','Njombe'),
('George Kapinga','0712345699','george.kaping@gmail.com','Shinyanga'),
('Theresa Kalonga','0712345700','theresa.kalonga@example.com','Rukwa'),
('Abdul Mchopo','0712345701','abdul.mchopo@example.com','Pemba'),
('Hilda Mrema','0712345702','hilda.mrema@example.com','Zanzibar'),
('Benard Lumumba','0712345703','benard.lumumba@example.com','Dar es Salaam'),
('Sabina Katundu','0712345704','sabina.katundu@example.com','Mwanza'),
('Edwin Mwinyi','0712345705','edwin.mwinyi@example.com','Manyara'),
('Catherine Lema','0712345706','catherine.lema@example.com','Dodoma'),
('Peter Nungu','0712345707','peter.nungu@example.com','Kilimanjaro');

INSERT INTO `fish_types` (`name`, `description`, `average_price_tzs`) VALUES
('Nile Perch','Large lake fish with firm white fillets','15000'),
('Tilapia','Popular freshwater fish','12000'),
('Catfish','Meaty fish ideal for grilling and frying','13000'),
('Freshwater Prawns','Premium shellfish from river systems','25000'),
('Tiger Fish','Spicy-textured predatory fish','18000'),
('Largemouth Bass','Freshwater sport fish with mild flavor','14000'),
('Carp','Freshwater fish used in stews and soups','9000'),
('Mudfish','Local freshwater species with soft flesh','10000'),
('Silver Cyprinid','Small whitefish for family meals','8500'),
('Climbing Perch','Hardy fish kept alive during transport','9500'),
('Moonfish','Delicate freshwater fish for roasting','11000'),
('Haplochromis','Lake species with firm texture','12500'),
('Freshwater Tilapia','Local tilapia variety from Lake Victoria','11500'),
('Redbreast Tilapia','Colorful tilapia for premium orders','14500'),
('Yellowtail Catfish','Large catfish with mild flavor','17000'),
('African Pike','Lean freshwater fish with rich taste','15500'),
('Mud Carp','Affordable fish for everyday meals','8800'),
('Silver Butterfish','Soft flaked fish for fast cooking','9800'),
('Spotted Tilapia','Market favorite with firm meat','12200'),
('Blue Tilapia','Fresh lake fish with mild aroma','11800'),
('Giant Tiger Prawn','Luxury shellfish for special delivery','32000'),
('Redear Sunfish','Local freshwater fish with sweet flesh','9400'),
('Bream','Mild and flaky fish for steaming','10200'),
('Mojarra','Popular fried fish with crisp skin','11200'),
('Yellow Catfish','Delicious freshwater fish for sauces','12800'),
('Rainbow Trout','Cool-water fish with firm texture','20000'),
('Silver Carp','High-volume freshwater fish for bulk orders','8700'),
('Stickleback','Small lake fish used in grills','9300'),
('Chambo','Premium Lake Malawi fish available by special order','26000'),
('Klunzinger''s Gourami','Exotic freshwater fish with delicate taste','21000');

INSERT INTO `destinations` (`name`, `region`, `distance_km`) VALUES
('Dar es Salaam','Coastal',980),
('Arusha','Arusha',560),
('Dodoma','Dodoma',648),
('Mbeya','Mbeya',900),
('Tanga','Tanga',940),
('Morogoro','Morogoro',740),
('Kigoma','Kigoma',1180),
('Shinyanga','Shinyanga',380),
('Tabora','Tabora',600),
('Iringa','Iringa',820),
('Mtwara','Mtwara',1070),
('Lindi','Lindi',1020),
('Singida','Singida',560),
('Njombe','Njombe',860),
('Songea','Songea',870),
('Musoma','Mara',190),
('Sumbawanga','Rukwa',1180),
('Bukoba','Kagera',360),
('Moshi','Kilimanjaro',570),
('Babati','Manyara',610),
('Pangani','Tanga',980),
('Kahama','Shinyanga',420),
('Mpwapwa','Dodoma',620),
('Ruangwa','Lindi',1030),
('Kondoa','Dodoma',620),
('Masasi','Mtwara',980),
('Mafia Island','Coastal',1100),
('Mahenge','Morogoro',780),
('Handeni','Tanga',870),
('Mpanda','Katavi',1250),
('Bukombe','Geita',450);

INSERT INTO `orders` (`customer_id`, `fish_type_id`, `destination_id`, `weight_kg`, `delivery_date`, `instructions`, `status`) VALUES
(1, 1, 2, 24, '2026-06-18', 'Pack with ice and deliver before 10:00.', 'Pending'),
(2, 3, 1, 18, '2026-06-19', 'Call ahead when arriving.', 'Scheduled'),
(3, 2, 3, 30, '2026-06-17', 'Keep chilled for two days.', 'In Transit'),
(4, 4, 4, 12, '2026-06-20', 'Use insulated container.', 'Pending'),
(5, 5, 5, 40, '2026-06-21', 'Deliver to wholesale market.', 'Scheduled'),
(6, 6, 6, 15, '2026-06-22', 'Handle carefully, no shaking.', 'Pending'),
(7, 7, 7, 20, '2026-06-23', 'Ensure cold chain remains intact.', 'In Transit'),
(8, 8, 8, 28, '2026-06-24', 'Notify driver on arrival.', 'Delivered'),
(9, 9, 9, 22, '2026-06-25', 'Pack in separate boxes.', 'Pending'),
(10, 10, 10, 35, '2026-06-26', 'Prepare customs documents.', 'Scheduled'),
(11, 11, 11, 26, '2026-06-27', 'Keep temperature between 0-4°C.', 'Pending'),
(12, 12, 12, 19, '2026-06-28', 'Deliver to cold storage facility.', 'Scheduled'),
(13, 13, 13, 14, '2026-06-29', 'Include receipt with delivery.', 'Pending'),
(14, 14, 14, 16, '2026-06-30', 'Pack in insulated boxes.', 'In Transit'),
(15, 15, 15, 23, '2026-07-01', 'Prefer afternoon delivery window.', 'Pending'),
(16, 16, 16, 29, '2026-07-02', 'Deliver to restaurant kitchen.', 'Scheduled'),
(17, 17, 17, 11, '2026-07-03', 'Temperature must remain stable.', 'Pending'),
(18, 18, 18, 13, '2026-07-04', 'Call 30 minutes before arrival.', 'Pending'),
(19, 19, 19, 21, '2026-07-05', 'Use separate packaging for prawns.', 'Delivered'),
(20, 20, 20, 33, '2026-07-06', 'Keep away from direct sunlight.', 'Scheduled'),
(21, 21, 21, 27, '2026-07-07', 'Deliver to the main fish market.', 'Pending'),
(22, 22, 22, 17, '2026-07-08', 'Ensure safe loading and unloading.', 'Pending'),
(23, 23, 23, 32, '2026-07-09', 'Keep cooler doors closed.', 'In Transit'),
(24, 24, 24, 20, '2026-07-10', 'Deliver directly to hotel kitchen.', 'Pending'),
(25, 25, 25, 18, '2026-07-11', 'Place fish on top of ice.', 'Scheduled'),
(26, 26, 26, 31, '2026-07-12', 'Pack each species separately.', 'Pending'),
(27, 27, 27, 29, '2026-07-13', 'Include order confirmation slip.', 'Pending'),
(28, 28, 28, 12, '2026-07-14', 'Deliver to local market stall.', 'Scheduled'),
(29, 29, 29, 25, '2026-07-15', 'Ensure transport documentation is ready.', 'Pending'),
(30, 30, 30, 22, '2026-07-16', 'Confirm arrival time with customer.', 'Pending');
