import semmle.python.Python

// 检测无限循环
from PyWhileStmt w
where w.condition is True
select w, "Potential infinite loop due to always true condition"

// 检测无限递归
from PyFunction f, PyCallExpr c
where c.calledFunction = f
and c.position is in f.body
select f, "Potential infinite recursion"

// 检测未关闭的文件资源
from PyCallExpr openCall
where openCall.fun.name = "open"
and not exists (PyWithStmt ws where ws.expression = openCall)
select openCall, "Resource leak: open call not closed"