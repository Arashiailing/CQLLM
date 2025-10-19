import python

from Call call, String s
where call.getTarget().getQualifiedName() in (
    "os.system",
    "subprocess.call",
    "subprocess.run",
    "subprocess.Popen"
) and 
    call.getArgs().exists(arg | 
        (arg.isStringLiteral() and 
         arg.getValue().toString().contains("$") or 
         arg.isVariable() and 
         s = arg.getStringValue() and 
         s.contains(" + ") and 
         s.contains("input") or 
         s.contains("eval") or 
         s.contains("exec"))
)
select call, "Potential command injection through improper handling of user input in command execution functions."