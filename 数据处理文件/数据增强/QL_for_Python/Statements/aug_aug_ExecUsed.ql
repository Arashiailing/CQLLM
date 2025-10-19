/**
 * @name 'exec' used
 * @description Detects usage of 'exec' statement/function which could lead to arbitrary code execution.
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
  // For Python 2: 'exec' is a statement
  result = "The 'exec' statement is used." and major_version() = 2
  // For Python 3: 'exec' is a function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Main detection logic for 'exec' usage
from AstNode execUsageNode
where 
  // Check for 'exec' function call via global variable access
  (exists(GlobalVariable execVariable | 
    execUsageNode instanceof Call and
    execVariable = execUsageNode.(Call).getFunc().(Name).getVariable() and 
    execVariable.getId() = "exec"
  ))
  or
  // Check for 'exec' statement (Python 2)
  execUsageNode instanceof Exec
// Output the detected node with appropriate warning message
select execUsageNode, getExecWarningMessage()