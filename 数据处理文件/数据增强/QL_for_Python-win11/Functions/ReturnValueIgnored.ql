/**
 * @name Ignored return value
 * @description Ignoring return values may result in discarding errors or loss of information.
 * @kind problem
 * @tags reliability
 *       readability
 *       convention
 *       statistical
 *       non-attributable
 *       external/cwe/cwe-252
 * @problem.severity recommendation
 * @sub-severity high
 * @precision medium
 * @id py/ignored-return-value
 */

import python
import semmle.python.objects.Callables

// 判断返回值是否具有实际意义
predicate meaningful_return_value(Expr val) {
  // 如果返回值是名称或布尔文字，则认为其有意义
  val instanceof Name
  or
  val instanceof BooleanLiteral
  or
  // 如果返回值是函数调用的结果且该函数返回有意义的值，则认为其有意义
  exists(FunctionValue callee |
    val = callee.getACall().getNode() and returns_meaningful_value(callee)
  )
  or
  // 如果返回值不是函数调用的结果且不是名称，则认为其有意义
  not exists(FunctionValue callee | val = callee.getACall().getNode()) and not val instanceof Name
}

/* Value is used before returning, and thus its value is not lost if ignored */
// 判断值是否在返回前被使用
predicate used_value(Expr val) {
  // 如果存在局部变量访问了该值且有其他访问，则认为该值被使用
  exists(LocalVariable var, Expr other |
    var.getAnAccess() = val and other = var.getAnAccess() and not other = val
  )
}

// 判断函数是否返回有意义的值
predicate returns_meaningful_value(FunctionValue f) {
  // 如果函数作用域中没有贯穿节点（如异常处理）
  not exists(f.getScope().getFallthroughNode()) and
  (
    // 如果函数中有返回语句且返回的值有意义且未被使用，则认为函数返回有意义的值
    exists(Return ret, Expr val | ret.getScope() = f.getScope() and val = ret.getValue() |
      meaningful_return_value(val) and
      not used_value(val)
    )
    or
    /*
     * Is f a builtin function that returns something other than None?
     * Ignore __import__ as it is often called purely for side effects
     */
    // 如果函数是内建函数且返回类型不是None且不是__import__函数，则认为其返回有意义的值
    f.isBuiltin() and
    f.getAnInferredReturnType() != ClassValue::nonetype() and
    not f.getName() = "__import__"
  )
}

/* If a call is wrapped tightly in a try-except then we assume it is being executed for the exception. */
// 判断表达式语句是否被紧密包裹在try-except块中
predicate wrapped_in_try_except(ExprStmt call) {
  // 如果存在一个try块且其中只有一个调用语句，则认为该调用语句被紧密包裹在try-except块中
  exists(Try t |
    exists(t.getAHandler()) and
    strictcount(Call c | t.getBody().contains(c)) = 1 and
    call = t.getAStmt()
  )
}

from ExprStmt call, FunctionValue callee, float percentage_used, int total
where
  // 获取调用语句和被调用的函数
  call.getValue() = callee.getACall().getNode() and
  // 函数返回有意义的值
  returns_meaningful_value(callee) and
  // 调用语句没有被紧密包裹在try-except块中
  not wrapped_in_try_except(call) and
  // 计算未使用的调用次数和总调用次数
  exists(int unused |
    unused = count(ExprStmt e | e.getValue().getAFlowNode() = callee.getACall()) and
    total = count(callee.getACall())
  |
    percentage_used = (100.0 * (total - unused) / total).floor()
  ) and
  /* Report an alert if we see at least 5 calls and the return value is used in at least 3/4 of those calls. */
  // 如果至少看到5次调用且返回值在至少3/4的调用中被使用，则报告警告
  percentage_used >= 75 and
  total >= 5
select call,
  "Call discards return value of function $@. The result is used in " + percentage_used.toString() +
    "% of calls.", callee, callee.getName()
