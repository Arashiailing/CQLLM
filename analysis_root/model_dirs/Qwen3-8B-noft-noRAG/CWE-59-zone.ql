import python

/** @predicate */
def isDangerousPathFunction(call: Call): bool {
  let func = call.getTarget()
  return func.getName() in ["os.path.join", "os.path.abspath", "os.path.normpath"] or
         func.getName() == "open" and call.getNumArgs() > 0
}

/** @predicate */
def hasUnsanitizedInput(call: Call): bool {
  let args = call.getArguments()
  for arg in args:
    if arg.isStringLiteral():
      return false
    if arg.isFromUserInput():
      return true
  return false
}

from Call call
where isDangerousPathFunction(call) and hasUnsanitizedInput(call)
select call, "Potential Path Injection vulnerability via unsafe file path construction."