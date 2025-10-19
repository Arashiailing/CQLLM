import python

from Call inputCall, Call dangerousCall
where (inputCall.getDecl().getName() = "input" or inputCall.getDecl().getName() = "sys.stdin.read")
  and dangerousCall.getArgument(0).getVariable() = inputCall.getReturnValue()
  and dangerousCall.getDecl().getName() in ["os.system", "eval", "exec", "subprocess.check_output"]
select dangerousCall, "Potential CWE-20: Improper Input Validation"