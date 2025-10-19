import python

/**
 * CWE-532: Insertion of Sensitive Information into Log File
 */
from FunctionCall fc, DataFlow::Node src, DataFlow::Node sink
where
  // Check if the function call is a logging function
  fc.getCallee().getName() = "log" or
  fc.getCallee().getName() = "info" or
  fc.getCallee().getName() = "debug" or
  fc.getCallee().getName() = "warning" or
  fc.getCallee().getName() = "error" or
  fc.getCallee().getName() = "critical" and
  // Check if the data flow from a source to a sink involves sensitive information
  DataFlow::localFlow(src, sink) and
  // Check if the source is a sensitive data source
  src instanceof SensitiveData and
  // Check if the sink is a log file
  sink instanceof LogFile
select fc, "This function call logs sensitive information to a file."