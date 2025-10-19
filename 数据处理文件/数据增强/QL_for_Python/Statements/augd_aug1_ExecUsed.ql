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

// Import the Python module for code analysis
import python

// Generate appropriate error message based on the Python version
string getErrorMessage() {
  // For Python 2, return message about exec statement
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // For Python 3, return message about exec function
  major_version() = 3 and result = "The 'exec' function is used."
}

// Identify calls to the exec function in the codebase
predicate isExecFunctionCall(Call functionCall) {
  // Check if the call references a global variable named 'exec'
  exists(GlobalVariable execGlobalVar | 
    execGlobalVar = functionCall.getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  )
}

// Find all instances of exec usage in the AST
from AstNode problematicNode
// Filter for either exec function calls or exec statements
where 
  isExecFunctionCall(problematicNode) 
  or 
  problematicNode instanceof Exec
// Return the problematic node along with the corresponding error message
select problematicNode, getErrorMessage()