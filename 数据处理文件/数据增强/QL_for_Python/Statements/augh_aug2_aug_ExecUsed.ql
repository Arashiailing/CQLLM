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

// Import the Python library for code parsing and security analysis
import python

/**
 * Constructs a version-specific error message for exec usage.
 * Returns different messages based on the Python version being used.
 */
string getExecErrorMessageByVersion() {
  // For Python 2 where exec is a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // For Python 3 where exec is a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

/**
 * Identifies function calls to the built-in exec function.
 * Matches calls that reference the global 'exec' variable.
 */
predicate isExecFunctionCall(Call functionCall) {
  // Verify the call references a global variable named 'exec'
  exists(GlobalVariable globalExecVar | 
    globalExecVar = functionCall.getFunc().(Name).getVariable() and 
    globalExecVar.getId() = "exec"
  )
}

// Main query to detect all dangerous exec usages in the code
from AstNode riskyExecNode
// Check if the node represents either an exec function call or an exec statement
where 
  isExecFunctionCall(riskyExecNode) 
  or 
  riskyExecNode instanceof Exec
// Output the risky exec usage node with an appropriate version-specific error message
select riskyExecNode, getExecErrorMessageByVersion()