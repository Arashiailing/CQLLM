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

// Generates a version-specific warning message based on the Python version in use
string generateVersionSpecificExecWarning() {
  // For Python 2, where exec is a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // For Python 3, where exec is a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Identifies function calls to exec that could potentially execute arbitrary code
predicate isPotentiallyDangerousExecCall(Call execFunctionCall) {
  // Check if the function call references a global variable named 'exec'
  exists(GlobalVariable globalExecVariable | 
    globalExecVariable = execFunctionCall.getFunc().(Name).getVariable() and 
    globalExecVariable.getId() = "exec"
  )
}

// Main analysis query to detect and report all potentially dangerous exec usages
from AstNode riskyExecUsage
// Determine if the node represents either an exec function call or an exec statement
where 
  isPotentiallyDangerousExecCall(riskyExecUsage) 
  or 
  riskyExecUsage instanceof Exec
// Report the exec usage with an appropriate version-specific warning message
select riskyExecUsage, generateVersionSpecificExecWarning()