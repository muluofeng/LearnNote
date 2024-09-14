这里的1和4，代表的并不是存储在数据库中的具体的长度，以前总是会误以为int(3)只能存储3个长度的数字，int(11)就会存储11个长度的数字，这是大错特错的。

tinyint(1) 和 tinyint(4) 中的1和4并不表示存储长度，只有字段指定zerofill是有用，
如tinyint(4)，如果实际值是2，如果列指定了zerofill，查询结果就是0002，左边用0来填充。




![images](https://note.youdao.com/yws/public/resource/2a5b7fb6fd0370dba39af73e2bc990b9/xmlnote/0C0124BD7F944F5E91F2FCABA35B49BD/1156)