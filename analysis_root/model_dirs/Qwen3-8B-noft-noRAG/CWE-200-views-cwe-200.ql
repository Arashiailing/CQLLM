import python
import semmle.code.cpp.dataflow.DataFlow

/** @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor */
/** @description Detects potential exposure of sensitive information through logging, error messages, or debug output */

from PrintStmt, StringLiteral
where PrintStmt.getTarget().hasName("print") 
  and PrintStmt.getArg(0).matches(StringLiteral)
  and StringLiteral.getValue().matches(/.*(?:password|secret|key|token|credential|api_key|database|username|password|private|sensitive).*./i)
select PrintStmt, "Potential exposure of sensitive information in print statement"

from LoggingCall, StringLiteral
where LoggingCall.getMethod().getName().matches("info|debug|warning|error|exception")
  and LoggingCall.getArg(0).matches(StringLiteral)
  and StringLiteral.getValue().matches(/.*(?:password|secret|key|token|credential|api_key|database|username|password|private|sensitive).*./i)
select LoggingCall, "Potential exposure of sensitive information in log message"

from ExceptHandler, StringLiteral
where ExceptHandler.getHandler().hasName("except")
  and ExceptHandler.getExceptType().toString().matches(".*Exception.*")
  and ExceptHandler.getBody().getStmts().exists(PrintStmt)
  and PrintStmt.getArg(0).matches(StringLiteral)
  and StringLiteral.getValue().matches(/.*(?:password|secret|key|token|credential|api_key|database|username|password|private|sensitive).*./i)
select PrintStmt, "Potential exposure of sensitive information in exception handling"