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

// Function to create a version-specific warning message about exec usage
string constructVersionSpecificWarning() {
  // Python 2 uses exec statement
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // Python 3 uses exec function
  major_version() = 3 and result = "The 'exec' function is used."
}

// Predicate that identifies calls to the exec function
predicate isExecFunctionCall(Call callNode) {
  // Check if the call targets a global variable named 'exec'
  exists(GlobalVariable globalExecVariable | 
    globalExecVariable = callNode.getFunc().(Name).getVariable() and 
    globalExecVariable.getId() = "exec"
  )
}

// Main query to detect all exec usage patterns in the codebase
from AstNode execNode
// Match either exec function calls or exec statements
where isExecFunctionCall(execNode) or execNode instanceof Exec
// Output the detected node with appropriate warning message
select execNode, constructVersionSpecificWarning()