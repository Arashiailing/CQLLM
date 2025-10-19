import python

/**
 * CWE-532: Insertion of Sensitive Information into Log File
 */

from Call call, StringLiteral sensitiveData, StringLiteral logFile
where call.getCallee().getName() = "log" and
      call.getArgument(0) = sensitiveData and
      call.getArgument(1) = logFile and
      sensitiveData.getValue() =~ /password|secret|token|key/i
select call, "Sensitive information is being logged to a file."