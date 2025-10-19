import python

// 检测直接比较明文密码
from Call call
where call.getMethod().getName() = "==" and 
      call.getArg(0).getType().getName() = "str" and 
      call.getArg(1).getType().getName() = "str"
select call, "Direct comparison of plain text passwords is insecure."

// 检测硬编码的凭证
from StringLiteral sl
where sl.getValue() matches /[a-zA-Z0-9]{8,}/ and 
      sl.getValue() not matches /password|secret|admin/
select sl, "Potential hardcoded credential found."

// 检测缺少身份验证检查的认证逻辑
from Method m
where m.getName() = "authenticate" or m.getName() = "login"
and not exists (m.getCall().getArg(0).getType().getName() = "User" and m.getCall().getArg(1).getType().getName() = "String")
select m, "Authentication method lacks proper credential verification."