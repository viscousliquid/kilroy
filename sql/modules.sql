CREATE TABLE IF NOT EXISTS `modules` (
  /* id is the global unique revision control number. 
      This is because AR is dependant on id being unique */
  `id`            int(11)       NOT NULL AUTO_INCREMENT,
  `mod_id`        int(11)       NOT NULL,
  `name`          varchar(56)   DEFAULT NULL,
  `description`   varchar(255)  DEFAULT NULL,
  `state`         int           DEFAULT NULL,
  `body`          text,
  `rev_user_id`   int(11)       NOT NULL,
  `rev_time`      timestamp     DEFAULT NOW(),
  PRIMARY KEY (`id`,`mod_id`)
)

