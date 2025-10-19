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

// Generates a version-specific alert message for 'exec' usage
string generateExecWarning() {
  // In Python 2: 'exec' is implemented as a statement
  result = "The 'exec' statement is used." and major_version() = 2
  // In Python 3: 'exec' is implemented as a built-in function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Main query to identify all 'exec' usage patterns in the codebase
from AstNode execNode
where 
  // Check for 'exec' function calls via global variable access
  (exists(GlobalVariable execGlobalVar | 
    execNode instanceof Call and
    execGlobalVar = execNode.(Call).getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  ))
  or
  // Check for 'exec' statement (Python 2 specific syntax)
  execNode instanceof Exec
// Report each identified node with its corresponding version-specific warning
select execNode, generateExecWarning()