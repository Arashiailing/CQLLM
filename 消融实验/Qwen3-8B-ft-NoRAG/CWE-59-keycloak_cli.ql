import python

from PyFunctionCall call
where call.getName() in ["os.system", "subprocess.check_output", "os.popen", "subprocess.call", "open"]
  and call.getArgument(0).getExpression() is not null
  and call.getArgument(0).getExpression().getStringLiteral().getValue().matches(".*\.\./.*")
select call, "Potential CWE-59: Improper link resolution in file access ('Link Following') due to path traversal patterns in arguments."