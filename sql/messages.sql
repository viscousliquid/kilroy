CREATE TABLE IF NOT EXISTS `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mtype` int NOT NULL,
  `time` timestamp DEFAULT NOW(),
  `room` varchar(56) DEFAULT NULL,
  `jid` varchar(255) DEFAULT NULL,
  `private` boolean DEFAULT NULL,
  `message` text,
  PRIMARY KEY (`id`)
)

