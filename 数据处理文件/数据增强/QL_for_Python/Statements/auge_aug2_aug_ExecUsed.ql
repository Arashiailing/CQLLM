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

// Creates version-specific error message based on Python version
string getExecVersionSpecificMessage() {
  // Python 2 uses exec as a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // Python 3 uses exec as a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Detects invocations of the exec function
predicate isExecFunctionCall(Call functionCall) {
  // Verify the call references a global variable named 'exec'
  exists(GlobalVariable globalExecVar | 
    globalExecVar = functionCall.getFunc().(Name).getVariable() and 
    globalExecVar.getId() = "exec"
  )
}

// Identifies any dangerous usage of exec (either as statement or function)
predicate isDangerousExecUsage(AstNode riskyExecUsage) {
  isExecFunctionCall(riskyExecUsage) 
  or 
  riskyExecUsage instanceof Exec
}

// Select all AST nodes representing dangerous exec usage
from AstNode riskyExecUsage
where isDangerousExecUsage(riskyExecUsage)
// Output the exec usage node with appropriate version-specific error message
select riskyExecUsage, getExecVersionSpecificMessage()