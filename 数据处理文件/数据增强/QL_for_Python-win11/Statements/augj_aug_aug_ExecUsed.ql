/**
 * @name 'exec' usage detection
 * @description Identifies usage of 'exec' statement/function which may lead to arbitrary code execution vulnerabilities.
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
 * Generates version-specific warning message for 'exec' usage
 * @returns Warning message string tailored to Python version
 */
string getExecWarningMessage() {
  // Python 2: 'exec' is a statement
  result = "The 'exec' statement is used." and major_version() = 2
  // Python 3: 'exec' is a function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Main detection logic for 'exec' usage
from AstNode detectedExecNode
where 
  // Case 1: 'exec' function call via global variable access
  exists(GlobalVariable execGlobalVar | 
    detectedExecNode instanceof Call and
    execGlobalVar = detectedExecNode.(Call).getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  )
  or
  // Case 2: 'exec' statement (Python 2 specific)
  detectedExecNode instanceof Exec
// Output detected node with appropriate version-specific warning
select detectedExecNode, getExecWarningMessage()