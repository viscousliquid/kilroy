CREATE TABLE IF NOT EXISTS `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `etype` int NOT NULL,
  `time` timestamp DEFAULT NOW(),
  `message` text,
  `trace` text,
  PRIMARY KEY (`id`)
)

