/**
 * @name 'exec' used
 * @description Detects usage of the 'exec' statement or function which may lead to arbitrary code execution.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// Import Python module for code analysis
import python

// Generate appropriate error message based on Python version
string message() {
  // For Python 2, return message about exec statement
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // For Python 3, return message about exec function
  major_version() = 3 and result = "The 'exec' function is used."
}

// Identify calls to the exec function
predicate exec_function_call(Call callNode) {
  // Check if the call references a global variable named 'exec'
  exists(GlobalVariable execVar | 
    execVar = callNode.getFunc().(Name).getVariable() and 
    execVar.getId() = "exec"
  )
}

// Find all exec usage nodes in the AST
from AstNode execNode
// Filter for either exec function calls or exec statements
where exec_function_call(execNode) or execNode instanceof Exec
// Return the problematic node and corresponding message
select execNode, message()