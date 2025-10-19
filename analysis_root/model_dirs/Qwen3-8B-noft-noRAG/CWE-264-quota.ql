import python

from Call call, String string, StringPart part
where call.getCallee() = "subprocess.run" or call.getCallee() = "os.system"
  and call.getArgumentCount() > 0
  and string = call.getArgument(0)
  and part.getStringPart(string) is not null
  and part.getSource() is not null
  and part.getSource().isUserInput()
select call, "Potential command injection vulnerability through unvalidated user input in subprocess/os.system call."