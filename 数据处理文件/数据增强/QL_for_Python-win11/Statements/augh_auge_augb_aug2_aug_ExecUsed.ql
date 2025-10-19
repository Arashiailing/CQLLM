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

// Import the Python library for code parsing and security analysis
import python

// Generate a version-specific warning message based on the Python version being used
// This helps developers understand which form of 'exec' (statement or function) is being detected
string createVersionSpecificExecWarning() {
  // For Python 2, 'exec' is a statement that can execute arbitrary code
  major_version() = 2 and result = "The 'exec' statement is used."
  // For Python 3, 'exec' is a function that can execute arbitrary code
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Identify function calls to the built-in 'exec' function which can execute arbitrary code
// This is a security risk as it allows dynamic code execution
predicate representsUnsafeExecFunctionCall(Call execFunctionCall) {
  // Check if the function call references the global variable named 'exec'
  // This ensures we're detecting the actual built-in 'exec' function, not a user-defined function with the same name
  exists(GlobalVariable globalExecVariable | 
    globalExecVariable = execFunctionCall.getFunc().(Name).getVariable() and 
    globalExecVariable.getId() = "exec"
  )
}

// Main query to find all instances of potentially dangerous 'exec' usage
// Both exec statements (Python 2) and exec function calls (Python 2 and 3) are detected
from AstNode dangerousExecUsage
// Check if the node represents either an exec function call or an exec statement
// This covers both forms of 'exec' usage across different Python versions
where 
  representsUnsafeExecFunctionCall(dangerousExecUsage) 
  or 
  dangerousExecUsage instanceof Exec
// Report the exec usage with an appropriate version-specific warning message
// This helps developers identify and remediate the security risk
select dangerousExecUsage, createVersionSpecificExecWarning()