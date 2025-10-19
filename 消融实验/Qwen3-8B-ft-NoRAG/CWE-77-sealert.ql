import py

from Call call
where call.getTarget().getName() in ("subprocess.run", "subprocess.call", "os.system") and
      (call.getArgument(0) is StringLiteral and
       (call.getArgument(0).getValue() contains "$" or
        call.getArgument(0).getValue() contains "`" or
        call.getArgument(0).getValue() contains "|" or
        call.getArgument(0).getValue() contains ">" or
        call.getArgument(0).getValue() contains "<" or
        call.getArgument(0).getValue() contains "&" or
        call.getArgument(0).getValue() contains ";") or
       (call.getArgument(2) is StringLiteral and
        call.getArgument(2).getValue() = "True"))
select call, "Potential command injection via command string with special characters or shell=True"