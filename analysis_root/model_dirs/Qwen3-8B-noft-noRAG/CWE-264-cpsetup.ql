import python

from MethodInvoke, StringLiteral, Parameter
where 
  (MethodInvoke.methodName = "tarfile.open" or 
   MethodInvoke.methodName = "subprocess.run" or 
   MethodInvoke.methodName = "subprocess.check_output") and
  exists(Parameter.paramIndex = 0 and Parameter.value = StringLiteral.literal)
select MethodInvoke, "Potential CWE-264 (TarSlipQuery) vulnerability detected: insecure tar file handling"