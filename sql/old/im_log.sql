CREATE TABLE IF NOT EXISTS `im_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime DEFAULT NULL,
  `jid` varchar(255) DEFAULT NULL,
  `message` text,
  PRIMARY KEY (`id`)
)
