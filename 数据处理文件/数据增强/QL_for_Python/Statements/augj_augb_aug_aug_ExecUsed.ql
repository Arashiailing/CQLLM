/**
 * @name 'exec' used
 * @description Identifies occurrences of the 'exec' statement/function that can potentially lead to arbitrary code execution vulnerabilities.
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

// Creates a tailored alert message based on the Python version in use
string createVersionSpecificExecWarning() {
  // For Python 2: 'exec' is implemented as a statement
  result = "The 'exec' statement is used." and major_version() = 2
  // For Python 3: 'exec' is implemented as a built-in function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Primary query logic to detect all instances of 'exec' usage
from AstNode execInstance
where 
  // Identify 'exec' function calls through global variable access
  (exists(GlobalVariable globalExecVariable | 
    execInstance instanceof Call and
    globalExecVariable = execInstance.(Call).getFunc().(Name).getVariable() and 
    globalExecVariable.getId() = "exec"
  ))
  or
  // Identify 'exec' statement (Python 2 specific syntax)
  execInstance instanceof Exec
// Report each detected instance with its appropriate version-specific warning
select execInstance, createVersionSpecificExecWarning()