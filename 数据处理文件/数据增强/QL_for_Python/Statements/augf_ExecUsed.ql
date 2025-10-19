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

/**
 * Generates version-specific warning message for 'exec' usage
 * @returns "The 'exec' statement is used" for Python 2
 *          "The 'exec' function is used" for Python 3
 */
string getExecWarningMessage() {
  result = "The 'exec' statement is used." and major_version() = 2
  or
  result = "The 'exec' function is used." and major_version() = 3
}

/**
 * Identifies function calls to built-in 'exec'
 * @param callNode - AST node representing the function call
 */
predicate isExecFunctionCall(Call callNode) {
  exists(GlobalVariable execVar |
    execVar = callNode.getFunc().(Name).getVariable() and
    execVar.getId() = "exec"
  )
}

// Main query logic
from AstNode execNode
where 
  isExecFunctionCall(execNode) or
  execNode instanceof Exec
select execNode, getExecWarningMessage()