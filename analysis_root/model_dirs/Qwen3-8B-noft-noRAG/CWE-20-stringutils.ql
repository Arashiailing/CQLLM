import python

/**
 * Query to detect CWE-20: Improper Input Validation in Python code.
 */
from Call call
where 
  // Identify potential input sources (e.g., user input functions)
  (call.getTarget() = "builtins.input" or 
   call.getTarget() = "sys.stdin.read" or 
   call.getTarget() = "argparse.ArgumentParser.parse_args") and
  // Check for lack of validation after input collection
  not exists (
    select MethodCall mc
    where mc.getQualifier().getName() = "str" and
          mc.getMethodName() in ("isalnum", "isdigit", "isalpha", "isdecimal", "islower", "isnumeric", "istitle", "isupper") and
          mc.getSource() = call.getResult()
  ) and
  // Detect unsafe usage of unvalidated input
  (exists (
    select New n
    where n.getType().getName() = "list" and
          n.getArgument(0).getExpression().toString() = call.getResult()
  ) or
  exists (
    select Call c
    where c.getTarget() = "subprocess.check_output" and
          c.getArguments()[0].getExpression().toString() = call.getResult()
  ) or
  exists (
    select Call c
    where c.getTarget() = "os.system" and
          c.getArguments()[0].getExpression().toString() = call.getResult()
  ))
select call.getLocation(), "Potential CWE-20: Improper Input Validation detected - unvalidated input used without proper checks"