import python

from Call call, StringLiteral literal
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.Popen" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen"
  and call.getArgument(0) = literal
select call, "Uncontrolled command line argument: " + literal.getValue()