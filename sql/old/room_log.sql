CREATE TABLE IF NOT EXISTS `room_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime DEFAULT NULL,
  `room` varchar(255) DEFAULT NULL,
  `jid` varchar(255) DEFAULT NULL,
  `private` boolean DEFAULT FALSE,
  `message` text,
  PRIMARY KEY (`id`)
)
