/**
 * @name 'exec' used
 * @description Detects usage of 'exec' statement/function which can execute arbitrary code
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

// Generates version-specific warning message for exec usage
string getExecWarningMessage() {
  result = "The 'exec' statement is used." and major_version() = 2
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Identifies calls to the global 'exec' function
predicate isExecFunctionCall(Call callNode) {
  exists(GlobalVariable execVar | 
    execVar = callNode.getFunc().(Name).getVariable() and 
    execVar.getId() = "exec"
  )
}

// Select all AST nodes representing exec usage
from AstNode execNode
where isExecFunctionCall(execNode) or execNode instanceof Exec
select execNode, getExecWarningMessage()