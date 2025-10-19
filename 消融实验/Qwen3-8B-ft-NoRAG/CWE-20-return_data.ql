import python

/**
 * 检测日志注入漏洞：未正确验证或转义用户输入到日志消息中
 */
from Call call, Argument arg
where 
  call.getCallee().getName() in ("debug", "info", "warning", "error", "critical") 
  and call.getModule().getName() = "logging"
  and arg.getArgumentIndex() = 0
  and arg.getExpression().isStringLiteral()
  and arg.getExpression().getValue() like "%{user_input}%"
select call, "检测到日志注入漏洞：日志消息直接拼接了未经验证的用户输入"