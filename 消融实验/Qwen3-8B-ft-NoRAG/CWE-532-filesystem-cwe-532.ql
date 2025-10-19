import python

from Call call, StringLiteral str, VarDecl var
where call.getTarget().getName() in ["debug", "info", "warning", "error", "critical"]
  and call.getModule().getName() = "logging"
  and (call.getArgument(0).getSymbol() = str or call.getArgument(0).getSymbol() = var)
  and (str.getValue() matches /password|secret|token|key|cred|auth/i 
       or var.getName() matches /password|secret|token|key|cred|auth/i)
select call, "Potential sensitive data logged in log message."