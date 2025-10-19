import py

from CallExpr call
where call.getTarget().getName() in ("md5", "sha1")
select call, "使用不安全的哈希算法（MD5或SHA-1）"