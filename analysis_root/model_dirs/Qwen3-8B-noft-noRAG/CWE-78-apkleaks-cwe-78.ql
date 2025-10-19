import python

from Call call, Argument arg
where 
  (call.getCallee() = "subprocess.run" or 
   call.getCallee() = "subprocess.call" or 
   call.getCallee() = "subprocess.exec" or 
   call.getCallee() = "os.system") and 
  arg.getArgumentNumber() = 0 and 
  exists(Source src, StringLiteral str | 
    src.getSource() = str.getValue() and 
    call.getLocation().getFile() = src.getFile() and 
    call.getLocation().getLine() = src.getLine() and 
    str.getValue().contains("$") or 
    str.getValue().contains("`") or 
    str.getValue().contains("$( ") or 
    str.getValue().contains("$(\"") or 
    str.getValue().contains("$(('")) or 
    str.getValue().contains("$([")) or 
    str.getValue().contains("$(<"))
select call.getLocation(), "Potential command injection via uncontrolled string in command execution"