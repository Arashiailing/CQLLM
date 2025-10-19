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

// Import Python library for code analysis capabilities
import python

// Helper predicate to identify calls to the exec function
predicate isExecCall(Call callNode) {
  exists(GlobalVariable execGlobal | 
    execGlobal = callNode.getFunc().(Name).getVariable() and 
    execGlobal.getId() = "exec"
  )
}

// Generates appropriate warning message based on Python version
string getVersionSpecificWarning() {
  // Check Python major version and return corresponding warning
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Main query: Find all instances of exec usage (either as statement or function call)
from AstNode riskyExecUsage
where 
  isExecCall(riskyExecUsage) or 
  riskyExecUsage instanceof Exec
select riskyExecUsage, getVersionSpecificWarning()