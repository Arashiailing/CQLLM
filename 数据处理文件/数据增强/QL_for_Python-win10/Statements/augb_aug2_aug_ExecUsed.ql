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

// Constructs version-specific warning message for exec usage
string createVersionSpecificExecWarning() {
  // Python 2 uses exec as a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // Python 3 uses exec as a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Detects invocations of the exec function in source code
predicate isExecFunctionInvocation(Call functionCall) {
  // Verify the function call references a global variable named 'exec'
  exists(GlobalVariable execVariable | 
    execVariable = functionCall.getFunc().(Name).getVariable() and 
    execVariable.getId() = "exec"
  )
}

// Find all AST nodes representing potentially dangerous exec usage
from AstNode riskyExecNode
// Determine if the node represents either an exec function call or an exec statement
where 
  isExecFunctionInvocation(riskyExecNode) 
  or 
  riskyExecNode instanceof Exec
// Report the exec usage with an appropriate version-specific warning message
select riskyExecNode, createVersionSpecificExecWarning()