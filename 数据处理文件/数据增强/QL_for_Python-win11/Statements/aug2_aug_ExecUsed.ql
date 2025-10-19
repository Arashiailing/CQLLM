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

// Generates version-specific error message for exec usage
string generateExecVersionSpecificMessage() {
  // For Python 2 where exec is a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // For Python 3 where exec is a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Identifies calls to the exec function in the code
predicate identifyExecFunctionCall(Call invocation) {
  // Check if the invocation references a global variable named 'exec'
  exists(GlobalVariable execGlobalVar | 
    execGlobalVar = invocation.getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  )
}

// Select all AST nodes representing dangerous exec usage
from AstNode dangerousExecUsage
// Check if the node represents either an exec function call or an exec statement
where 
  identifyExecFunctionCall(dangerousExecUsage) 
  or 
  dangerousExecUsage instanceof Exec
// Output the exec usage node with appropriate version-specific error message
select dangerousExecUsage, generateExecVersionSpecificMessage()