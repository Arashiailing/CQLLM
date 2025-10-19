import python

from MethodInvoke call, StringLiteral lit, Variable var
where 
  // Match variable names that suggest sensitive data (e.g., password, secret)
  var.name.re.matches(".*?(pass|secret|token|key|cred).*") and
  // Check if the variable is assigned a string literal
  exists( Assignment assign |
    assign.lhs = var and
    assign.rhs is StringLiteral and
    assign.rhs.value!= null
  ) and
  // Check if the variable is used in a file write operation without encryption
  call.callee.name = "write" and
  call.receiver instanceof CallExpr and
  call.receiver.callee.name = "open" and
  call.receiver.args[0].value.toString() matches "/.*\.conf$|/.*\.ini$|/.*\.env$" and
  // Ensure no encryption is applied before writing
  not (exists( CallExpr encryptCall |
    encryptCall.calledMethod.name in ("encrypt", "cipher", "symmetric_encrypt", "base64encode")
  ))
select var, "Potential cleartext storage of sensitive data detected"