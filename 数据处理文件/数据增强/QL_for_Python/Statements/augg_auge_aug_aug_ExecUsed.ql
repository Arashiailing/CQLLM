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

// Generates version-specific warning message for 'exec' usage
string getExecWarningMessage() {
  // In Python 2, 'exec' is a statement
  result = "The 'exec' statement is used." and major_version() = 2
  or
  // In Python 3, 'exec' is a built-in function
  result = "The 'exec' function is used." and major_version() = 3
}

// Main detection logic for 'exec' usage
from AstNode dangerousExecNode
where 
  // Case 1: Python 2 'exec' statement
  dangerousExecNode instanceof Exec
  or
  // Case 2: Python 3 'exec' function call
  exists(GlobalVariable globalExecReference | 
    dangerousExecNode instanceof Call and
    globalExecReference = dangerousExecNode.(Call).getFunc().(Name).getVariable() and 
    globalExecReference.getId() = "exec"
  )
// Output detected node with appropriate warning message
select dangerousExecNode, getExecWarningMessage()