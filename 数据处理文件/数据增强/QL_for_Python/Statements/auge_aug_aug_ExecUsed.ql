/**
 * @name 'exec' usage detection
 * @description Identifies instances of 'exec' statement/function usage that may enable arbitrary code execution.
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
  // Python 2: 'exec' is a statement
  result = "The 'exec' statement is used." and major_version() = 2
  // Python 3: 'exec' is a function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Main detection logic for 'exec' usage
from AstNode execNode
where 
  // Check for Python 2 'exec' statement
  execNode instanceof Exec
  or
  // Check for Python 3 'exec' function call via global variable access
  exists(GlobalVariable globalExecVar | 
    execNode instanceof Call and
    globalExecVar = execNode.(Call).getFunc().(Name).getVariable() and 
    globalExecVar.getId() = "exec"
  )
// Output detected node with appropriate warning message
select execNode, getExecWarningMessage()