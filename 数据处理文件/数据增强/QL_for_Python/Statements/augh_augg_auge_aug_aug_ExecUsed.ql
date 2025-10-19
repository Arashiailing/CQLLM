/**
 * @name 'exec' usage detection
 * @description Identifies instances of 'exec' statement/function usage that may enable arbitrary code execution.
 * @details This query detects both Python 2 'exec' statements and Python 3 'exec' function calls.
 *          Using 'exec' can lead to arbitrary code execution, which is a significant security risk.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

import python

/**
 * Generates a version-specific warning message for 'exec' usage.
 * @returns A string warning message indicating the type of 'exec' usage detected.
 */
string getExecWarningMessage() {
  // For Python 2, where 'exec' is a statement
  result = "The 'exec' statement is used." and major_version() = 2
  or
  // For Python 3, where 'exec' is a built-in function
  result = "The 'exec' function is used." and major_version() = 3
}

// Main query to detect 'exec' usage in Python code
from AstNode riskyExecUsage
where 
  // Case 1: Python 2 'exec' statement
  riskyExecUsage instanceof Exec
  or
  // Case 2: Python 3 'exec' function call
  (
    riskyExecUsage instanceof Call and
    exists(GlobalVariable execGlobalVar | 
      execGlobalVar = riskyExecUsage.(Call).getFunc().(Name).getVariable() and 
      execGlobalVar.getId() = "exec"
    )
  )
// Output the detected node along with the appropriate warning message
select riskyExecUsage, getExecWarningMessage()