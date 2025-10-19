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

// Import Python module for AST analysis
import python

/**
 * Generates a version-specific warning message for exec usage
 * based on the Python major version being analyzed.
 */
string create_exec_warning_message() {
  // For Python 2, exec is implemented as a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // For Python 3, exec is implemented as a function
  major_version() = 3 and result = "The 'exec' function is used."
}

/**
 * Identifies calls to the exec function by checking if the call
 * targets a global variable named 'exec'.
 */
predicate detect_exec_function_call(Call callNode) {
  // Verify the call references a global variable named 'exec'
  exists(GlobalVariable execGlobalVariable | 
    execGlobalVariable = callNode.getFunc().(Name).getVariable() and 
    execGlobalVariable.getId() = "exec"
  )
}

// Main query to detect all exec usage patterns in the codebase
from AstNode execNode
// Match either exec function calls or exec statements
where detect_exec_function_call(execNode) or execNode instanceof Exec
// Output the detected node with appropriate warning message
select execNode, create_exec_warning_message()