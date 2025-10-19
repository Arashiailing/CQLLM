import py

// 检测无限循环（while循环没有break语句）
from WhileStmt w
where not exists (BreakStmt b where b.isInBody(w))
select w, "Infinite loop due to missing break"

// 检测未关闭的文件
from CallExpr ce1, CallExpr ce2
where ce1.callee.getName() = "open"
and ce2.callee.getName() = "close"
and ce2.isAfter(ce1)
select ce1, ce2, "File opened without closing"

// 检测递归调用无限制
from FunctionDecl f
where f.isRecursive()
and not exists (CallExpr ce where ce.callee = f and ce.hasArgument("max_depth") or ce.hasArgument("limit"))
select f, "Unbounded recursive function"