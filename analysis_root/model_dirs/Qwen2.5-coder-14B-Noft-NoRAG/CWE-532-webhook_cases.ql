import python

/**
 * This query detects the CWE-532 vulnerability: Insertion of Sensitive Information into Log File.
 * It searches for calls to logging functions that might log sensitive information.
 */

from Call call, StringLiteral sensitiveData
where call.getCallee().getName() = "log" and
      call.getArgument(0) = sensitiveData and
      sensitiveData.getValue() matches ".*password.*" or ".*secret.*" or ".*token.*"
select call, "This call to log() might log sensitive information."