import python

from Call call
where call.get_method().getName() = "input" or call.get_method().getName() = "raw_input" or 
      call.get_method().getName() = "eval" or call.get_method().getName() = "exec" or 
      call.get_method().getName() = "open" and call.get_arg(0).getValue().getString() = "sys.stdin"
select call, "Potential CWE-400: Uncontrolled resource consumption"