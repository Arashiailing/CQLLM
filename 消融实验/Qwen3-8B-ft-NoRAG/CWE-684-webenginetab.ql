import py

/**
 * 查询所有可能的URL重定向调用，其中参数未经过验证
 */
from Call call
where call.getCalleeName() = "redirect"
  and call.getArgument(0).isVariable()
  and call.getArgument(0).getVariable().isUserInput()
select call, "Potential CWE-684: Redirect to user-controlled URL"