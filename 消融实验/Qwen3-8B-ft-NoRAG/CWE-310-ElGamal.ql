import py

/**
 * 检测使用弱哈希算法处理敏感数据的模式
 */
from Call site, Argument
where
  site = Call site("hashlib.md5", [])
  or site = Call site("hashlib.sha1", [])
  and
  (Argument is Call site("builtins.input", []) 
   or Argument is Call site("some_module.get_password", []) 
   or Argument is Call site("request.form.get", ["password"]))
select site, "检测到使用弱哈希算法（MD5/SHA-1）处理敏感数据（如密码）"