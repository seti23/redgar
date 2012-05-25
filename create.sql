Table	Create Table
irc_url	CREATE TABLE `irc_url` (\n  `id` bigint(10) unsigned NOT NULL AUTO_INCREMENT,\n  `url` varchar(246) NOT NULL DEFAULT '',\n  `handleid` int(10) unsigned NOT NULL DEFAULT '0',\n  `channelid` int(10) unsigned NOT NULL DEFAULT '0',\n  `lastseen` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n  `title` varchar(500) NOT NULL DEFAULT 'no-title',\n  PRIMARY KEY (`id`)\n) ENGINE=InnoDB AUTO_INCREMENT=21528 DEFAULT CHARSET=utf8
Table	Create Table
irc_handle	CREATE TABLE `irc_handle` (\n  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,\n  `handle` varchar(250) CHARACTER SET latin1 NOT NULL DEFAULT '',\n  PRIMARY KEY (`id`),\n  UNIQUE KEY `handle` (`handle`)\n) ENGINE=InnoDB AUTO_INCREMENT=3098 DEFAULT CHARSET=utf8
Table	Create Table
irc_channel	CREATE TABLE `irc_channel` (\n  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,\n  `channel` varchar(125) NOT NULL DEFAULT '',\n  PRIMARY KEY (`id`),\n  UNIQUE KEY `channel` (`channel`)\n) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8
