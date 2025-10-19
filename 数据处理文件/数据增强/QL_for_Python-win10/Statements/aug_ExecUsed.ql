/**
 * @name 'exec' used
 * @description The 'exec' statement or function is used which could cause arbitrary code to be executed.
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

// Function to generate version-specific error message for exec usage
string getExecErrorMessage() {
  // Return message for Python 2 where exec is a statement
  result = "The 'exec' statement is used." and major_version() = 2
  // Return message for Python 3 where exec is a function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Predicate to identify calls to the exec function
predicate isExecFunctionCall(Call functionCall) {
  // Check if the call references a global variable named 'exec'
  exists(GlobalVariable execVariable | 
    execVariable = functionCall.getFunc().(Name).getVariable() and 
    execVariable.getId() = "exec"
  )
}

// Select all AST nodes representing exec usage
from AstNode execNode
// Condition: node is either an exec function call or an exec statement
where isExecFunctionCall(execNode) or execNode instanceof Exec
// Output the exec usage node with appropriate error message
select execNode, getExecErrorMessage()