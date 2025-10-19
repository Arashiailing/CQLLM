import semmle.code.py.Python
import semmle.code.py.security.SensitiveData

from Call call, StringParam param
where (call.getFunction().getName() in ["info", "debug", "warning", "error", "critical"] and
       call.getFunction().getModule().getName() = "logging") or
      (call.getFunction().getName() = "print" and call.getFunction().getModule().getName() = "builtins")
and call.getParameters() = param
and SensitiveData::isSensitiveString(param.getValue())
select call, "This log function call contains sensitive data."