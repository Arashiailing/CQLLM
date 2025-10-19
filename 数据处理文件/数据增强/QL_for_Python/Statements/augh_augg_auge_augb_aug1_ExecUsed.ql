/**
 * @name 'exec' used
 * @description Identifies instances where the 'exec' statement or function is utilized,
 *              which can potentially result in arbitrary code execution vulnerabilities.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// Import the Python analysis module to enable code examination
import python

// Helper function that generates a version-specific alert message regarding exec usage
string generateVersionDependentAlert() {
  // For Python 2, the exec statement is the relevant construct
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // For Python 3, the exec function is the relevant construct
  major_version() = 3 and result = "The 'exec' function is used."
}

// Predicate that determines if a given function call is an invocation of the exec function
predicate identifiesExecFunctionInvocation(Call functionInvocation) {
  // Verify that the call is directed to a global variable named 'exec'
  exists(GlobalVariable globalExecReference | 
    globalExecReference = functionInvocation.getFunc().(Name).getVariable() and 
    globalExecReference.getId() = "exec"
  )
}

// Primary query logic to identify all patterns of exec usage throughout the codebase
from AstNode detectedExecUsage
// Identify either exec function invocations or exec statements
where identifiesExecFunctionInvocation(detectedExecUsage) or detectedExecUsage instanceof Exec
// Present the identified node along with the appropriate warning message
select detectedExecUsage, generateVersionDependentAlert()