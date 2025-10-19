import python

from PyFunctionCall call, PyArg arg, PyStr string
where 
  call.fun.name = "subprocess.run" or 
  call.fun.name = "subprocess.check_output" or 
  call.fun.name = "os.system" or 
  call.fun.name = "shutil.executable"
  and arg.index = 0
  and arg.value = string
  and exists(PyVar var | var.name = string.value and var.source is PyInputSource)
select call, "Potential command injection vulnerability: unsanitized user input used in command execution."