/**
 * @name 'exec' used
 * @description Detects usage of 'exec' statement or function, which can lead to arbitrary code execution.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// Import Python library for analyzing Python code
import python

// Generate version-specific warning message for exec usage
string getAlertMessage() {
  // Return appropriate warning based on Python major version
  exists(int version | 
    version = major_version() and
    (
      version = 2 and result = "The 'exec' statement is used."
      or
      version = 3 and result = "The 'exec' function is used."
    )
  )
}

// Main query: Identify exec statements and function calls
from AstNode execNode
// Check for either exec statement or exec function call
where 
  // Case 1: Node is an exec statement
  execNode instanceof Exec
  or
  // Case 2: Node is an exec function call
  exists(GlobalVariable execVar | 
    execNode instanceof Call and
    execVar = execNode.(Call).getFunc().(Name).getVariable() and 
    execVar.getId() = "exec"
  )
// Return detected node with corresponding warning message
select execNode, getAlertMessage()