# WKeyChain 
以map方式操作keychain

find:group  			以key查找value，返回NSString，不存在时返回nil
findData:group 			以key查找value，返回NSData，不存在时返回nil
set:value:group			设置key/value对，存在时更新，不存在时添加。value=nil时删除。value类型为NSString
setData:value:group		等同于set:value:group, value类型为NSData
getAll:					返回所有的key/value对，value为NSString类型
getAllData:				返回所有的key/value对，value为NSData类型	
clear:					清空

group参数必须为nil或者为keychain share list中之一
