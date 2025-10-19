import py

from FunctionCall, FunctionParameter
where FunctionCall.getFunction().getName() in ["get", "post", "put", "patch", "delete"] 
  and FunctionCall.getModule().getName() = "requests"
  and exists(FunctionParameter where FunctionParameter.getName() = "verify" and FunctionParameter.getValue() = false)
select FunctionCall, "CWE-295: Improper Certificate Validation"