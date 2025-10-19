/**
 * @name 'exec' used
 * @description Detects usage of the 'exec' statement or function which can lead to arbitrary code execution.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// Import Python library for AST parsing and security analysis
import python

/**
 * Generates version-specific error message for exec usage.
 * Differentiates between Python 2 (exec as statement) and Python 3 (exec as function).
 */
string getVersionSpecificExecErrorMessage() {
  // Python 2 uses exec as a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // Python 3 uses exec as a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

/**
 * Identifies function calls to the built-in exec function.
 * This detects invocations of the exec function in Python 3 code.
 */
predicate isExecFunctionCall(Call functionCall) {
  // Check if the function call references a global variable named 'exec'
  exists(GlobalVariable globalExecVariable | 
    globalExecVariable = functionCall.getFunc().(Name).getVariable() and 
    globalExecVariable.getId() = "exec"
  )
}

// Main query to detect all dangerous exec usages in the code
from AstNode execUsageNode
// Match both exec function calls and exec statements
where 
  isExecFunctionCall(execUsageNode) or 
  execUsageNode instanceof Exec
// Report the exec usage with an appropriate version-specific error message
select execUsageNode, getVersionSpecificExecErrorMessage()