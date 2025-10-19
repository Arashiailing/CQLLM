import python

from CallExpr call, StringLiteral formatStr
where call.getCallee().getName() in ("info", "warning", "debug", "error", "critical") 
  and call.getArguments().size() > 0 
  and call.getArguments()[0] = formatStr 
  and formatStr.getValue() matches /%|\{.*\}/
select call, "Potential log injection vulnerability: format string with untrusted inputs used in logging"