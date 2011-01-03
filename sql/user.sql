CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `jid      varchar(255) DEFAULT NULL,
  `login`   varchar(25) DEFAULT NULL,
  `name`    varchar(56) DEFAULT NOT NULL,
  `gecos`   varchar(255) DEFAULT NULL,
  `admin`   boolean DEFAULT false,
  `pubkey`  text,
  PRIMARY KEY (`id`)
)

