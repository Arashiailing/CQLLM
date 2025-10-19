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

// Generate version-specific error message for exec usage
string getExecUsageMessage() {
  // Handle Python 2 case: exec as a statement
  exists(int version | version = major_version() |
    version = 2 and result = "The 'exec' statement is used."
  )
  or
  // Handle Python 3 case: exec as a function
  exists(int version | version = major_version() |
    version = 3 and result = "The 'exec' function is used."
  )
}

// Identify function calls to the built-in exec function
predicate isExecFunctionCall(Call functionCall) {
  // Verify the call targets a global variable named 'exec'
  exists(GlobalVariable execGlobalVar | 
    execGlobalVar = functionCall.getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  )
}

// Main query to detect all forms of exec usage
from AstNode execUsageNode
where 
  // Check for exec function calls
  isExecFunctionCall(execUsageNode)
  or
  // Check for exec statements (Python 2)
  execUsageNode instanceof Exec
// Return the detected exec usage node with appropriate message
select execUsageNode, getExecUsageMessage()