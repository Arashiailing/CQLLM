import python
from python.StringLiteral import StringLiteral
from python.Call import Call
import hashlib

// 检测使用不安全的哈希算法存储密码
select Call.getCallSite(Call.getFunction() = hashlib.md5 or Call.getFunction() = hashlib.sha1)

// 检测硬编码的密码字符串（简单模式）
select StringLiteral where regex_match(value, '^[a-zA-Z0-9!@#$%^&*]{8,}$')

// 检测将密码写入文件的操作
select Call where Call.getFunction() = python.Open and Call.getArgument(0).getValue() = "config.ini" and Call.getArgument(1).getValue() contains "password"