import py

from CallExpr call
where call.getCallee().getName() = "info" and call.getFunction().getQualifier() = "logging"
select call, "Potential Log Injection in logging call with unescaped user input."