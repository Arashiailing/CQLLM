/**
 * @name Detection of 'exec' usage patterns
 * @description Identifies potentially dangerous uses of 'exec' that can lead to arbitrary code execution.
 * @details This query detects both Python 2 'exec' statements and Python 3 'exec' function calls.
 *          The 'exec' construct allows dynamic execution of Python code, which can introduce serious
 *          security vulnerabilities if used with untrusted input.
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

// Generates appropriate warning message based on Python version
string generateExecWarning() {
  // Python 2 uses 'exec' as a statement
  result = "The 'exec' statement is used." and major_version() = 2
  or
  // Python 3 uses 'exec' as a built-in function
  result = "The 'exec' function is used." and major_version() = 3
}

// Primary detection logic for identifying 'exec' usage
from AstNode execUsageNode
where 
  // Detection for Python 2 'exec' statement
  execUsageNode instanceof Exec
  or
  // Detection for Python 3 'exec' function call
  exists(GlobalVariable execGlobalVar | 
    execUsageNode instanceof Call and
    execGlobalVar = execUsageNode.(Call).getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  )
// Output the detected node along with version-specific warning
select execUsageNode, generateExecWarning()