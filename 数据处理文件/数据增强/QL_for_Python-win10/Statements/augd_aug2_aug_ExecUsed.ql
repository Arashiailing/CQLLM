/**
 * @name 'exec' used
 * @description Detects usage of the 'exec' statement or function which can lead to arbitrary code execution vulnerabilities.
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

// Creates version-specific alert message based on Python version
string createVersionSpecificExecMessage() {
  // For Python 2 where exec is implemented as a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // For Python 3 where exec is implemented as a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Detects invocations of the exec function in the source code
predicate isExecFunctionInvocation(Call functionCall) {
  // Verify the invocation targets a global variable named 'exec'
  exists(GlobalVariable execGlobalReference | 
    execGlobalReference = functionCall.getFunc().(Name).getVariable() and 
    execGlobalReference.getId() = "exec"
  )
}

// Main query to identify all instances of dangerous exec usage
from AstNode riskyExecNode
// Check if the node represents either an exec function call or an exec statement
where 
  isExecFunctionInvocation(riskyExecNode) 
  or 
  riskyExecNode instanceof Exec
// Report the exec usage with appropriate version-specific error message
select riskyExecNode, createVersionSpecificExecMessage()