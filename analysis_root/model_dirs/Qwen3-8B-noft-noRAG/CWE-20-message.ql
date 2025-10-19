import python

from Call call
where call.getTarget().getKind() = "Function" and call.getFunctionName() in ["input", "raw_input"]
select call, "Potential CWE-20: Improper Input Validation - Unvalidated user input detected"