import python

from LoggerCall call
where call.getFunction().getName() = "info" or 
      call.getFunction().getName() = "debug" or 
      call.getFunction().getName() = "warning" or 
      call.getFunction().getName() = "error" or 
      call.getFunction().getName() = "critical"
select call, "Potential log injection: untrusted input directly used in log message."