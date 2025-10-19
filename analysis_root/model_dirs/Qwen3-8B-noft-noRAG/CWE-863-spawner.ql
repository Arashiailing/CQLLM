import python

/** @name CWE-863: Incorrect Authorization */
from Call call
where call.getSelector().getName() = "run" and call.getCallee().getKind() = "Function"
  and call.getArg(0).getType().getName() = "str"
  and exists(
    (call.getPosition().getFile(), call.getPosition().getStartLine()) as loc,
    (loc, "Missing authorization check before executing arbitrary command", "High")
  )
select call, "Potential incorrect authorization: subprocess.run called without proper validation"