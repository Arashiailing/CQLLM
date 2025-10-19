import python

from FunctionCall fc
where fc.getQualifiedName() = "os.system" or
      (fc.getQualifiedName().startsWith("subprocess.") and
       fc.getArgument(0).isString() and
       fc.getArgument(1).getName() = "shell" and
       fc.getArgument(1).getValue().isBoolean() and
       fc.getArgument(1).getValue().getBoolValue())
select fc, "Potential command injection via command execution function"