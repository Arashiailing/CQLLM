import python

/**
 * This query detects CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * by identifying logging of sensitive information in Python code.
 */

from FunctionCall logCall, StringLiteral sensitiveData
where logCall.getCallee().getName() = "log" and
      logCall.getArgument(0) = sensitiveData and
      sensitiveData.getValue() =~ /password|secret|token|key/i
select logCall, "Sensitive information is being logged in plaintext."