import python

/**
 * This query detects CWE-534: Information Exposure Through Debug Log Files.
 * It searches for Python code that writes sensitive information to log files
 * in a clear text format.
 */

from File file, CallExpr call
where call.getCallee().getName() = "write" and
      call.getArgument(0).asExpr() instanceof StringLiteral and
      call.getArgument(0).asExpr().getValue().matches(".*password.*|.*secret.*|.*key.*|.*token.*")
select file, "This file writes sensitive information to a log file in clear text: " + call.getArgument(0).asExpr().getValue()