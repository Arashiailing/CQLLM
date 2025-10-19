import python

/**
 * 检测服务器端模板注入漏洞，可能导致反射型XSS
 */
from Call call, Argument arg
where 
  call.getCallee().getName() = "render_template" and 
  arg.getArgumentIndex() = 0 and 
  arg.getValue().getExpression().isMemberAccess() and 
  arg.getValue().getExpression().getMemberName() = "args" and 
  arg.getValue().getExpression().getBase().getName() = "request"
select call, "检测到使用用户输入参数进行模板渲染，可能导致反射型XSS漏洞"