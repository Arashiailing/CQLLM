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

// Import Python library for code parsing and analysis
import python

/**
 * Generates a version-specific error message based on the Python version in use.
 * Python 2 treats 'exec' as a statement, while Python 3 treats it as a function.
 */
string generateExecVersionSpecificMessage() {
  // For Python 2, 'exec' is a statement
  result = "The 'exec' statement is used." and major_version() = 2
  // For Python 3, 'exec' is a function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

/**
 * Determines if a given invocation is a call to the 'exec' function.
 * This is identified by checking if the function being called references
 * a global variable named 'exec'.
 */
predicate isCallToExecFunction(Call invocation) {
  exists(GlobalVariable globalExecVar | 
    globalExecVar = invocation.getFunc().(Name).getVariable() and 
    globalExecVar.getId() = "exec"
  )
}

// Main query to find all usages of 'exec' in the code
from AstNode execUsageNode
// Filter for nodes that are either calls to the 'exec' function or 'exec' statements
where isCallToExecFunction(execUsageNode) or execUsageNode instanceof Exec
// Output the exec usage node along with the appropriate error message
select execUsageNode, generateExecVersionSpecificMessage()