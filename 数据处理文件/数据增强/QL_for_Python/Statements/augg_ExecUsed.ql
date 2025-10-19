/**
 * @name 'exec' used
 * @description Detects usage of 'exec' statement/function which enables arbitrary code execution
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

import python

// Generates version-specific warning message for 'exec' usage
string getWarningMessage() {
  // Python 2 uses 'exec' statement
  result = "The 'exec' statement is used." and major_version() = 2
  // Python 3 uses 'exec' function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Identifies calls to the 'exec' built-in function
predicate isExecFunctionCall(Call functionCall) {
  exists(GlobalVariable execVar | 
    execVar = functionCall.getFunc().(Name).getVariable() and 
    execVar.getId() = "exec"
  )
}

// Main query: Find all 'exec' usages (statement or function call)
from AstNode execNode
where 
  // Check for function call usage
  isExecFunctionCall(execNode) 
  or 
  // Check for statement usage
  execNode instanceof Exec
// Return the node and version-specific warning message
select execNode, getWarningMessage()