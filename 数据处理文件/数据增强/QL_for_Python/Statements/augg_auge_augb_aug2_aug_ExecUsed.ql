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

// Creates a version-specific warning message for exec usage
string constructExecWarningMessage() {
  // Python 2 uses exec as a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // Python 3 uses exec as a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Identifies calls to the exec function that may execute arbitrary code
predicate isExecFunctionInvocation(Call execCall) {
  // Verify the function call references a global variable named 'exec'
  exists(GlobalVariable referencedExecVar | 
    referencedExecVar = execCall.getFunc().(Name).getVariable() and 
    referencedExecVar.getId() = "exec"
  )
}

// Main query to locate and report all potentially dangerous exec usages
from AstNode dangerousExecNode
// Check if the node represents either an exec function call or an exec statement
where 
  isExecFunctionInvocation(dangerousExecNode) 
  or 
  dangerousExecNode instanceof Exec
// Report the exec usage with an appropriate version-specific warning message
select dangerousExecNode, constructExecWarningMessage()