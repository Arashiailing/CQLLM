/**
 * @name 'exec' used
 * @description Identifies usage of the 'exec' statement or function which can lead to arbitrary code execution.
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

// Generates a version-specific warning message based on Python version
string getVersionSpecificWarning() {
  // Python 2 uses exec as a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // Python 3 uses exec as a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Detects function calls to exec that could execute arbitrary code
predicate isDangerousExecCall(Call execFunctionCall) {
  // Check if the function call references a global variable named 'exec'
  exists(GlobalVariable globalExecVar | 
    globalExecVar = execFunctionCall.getFunc().(Name).getVariable() and 
    globalExecVar.getId() = "exec"
  )
}

// Main query to find and report all potentially unsafe exec usages
from AstNode riskyExecUsage
// Determine if the node represents either an exec function call or an exec statement
where 
  isDangerousExecCall(riskyExecUsage) 
  or 
  riskyExecUsage instanceof Exec
// Report the exec usage with an appropriate version-specific warning message
select riskyExecUsage, getVersionSpecificWarning()