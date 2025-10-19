import py

from Call call, Argument arg
where 
  call.getMethod().getName() in ["subprocess.run", "subprocess.check_output", "os.system", "subprocess.Popen"] and
  arg.getArgumentIndex() = 0 and
  arg.getExpression().isVariable() and
  arg.getExpression().getVariable().getOrigin().isUserInput()
select call, "Potential CWE-20: Improper Input Validation - Unsanitized command argument"