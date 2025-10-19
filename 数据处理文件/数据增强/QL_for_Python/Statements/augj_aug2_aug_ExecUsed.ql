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

// Import Python library for AST parsing and security analysis
import python

// Generates version-specific warning message for exec usage
string getVersionSpecificExecWarning() {
  // For Python 2 where exec is a statement
  major_version() = 2 and result = "The 'exec' statement is used."
  // For Python 3 where exec is a function
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Identifies invocations of the exec function in the codebase
predicate isExecFunctionInvocation(Call functionCall) {
  // Check if the invocation references a global variable named 'exec'
  exists(GlobalVariable globalExecVariable | 
    globalExecVariable = functionCall.getFunc().(Name).getVariable() and 
    globalExecVariable.getId() = "exec"
  )
}

// Determines if a node represents a dangerous usage of exec
predicate isRiskyExecUsage(AstNode node) {
  isExecFunctionInvocation(node) or node instanceof Exec
}

// Select all AST nodes representing dangerous exec usage
from AstNode riskyExecNode
where isRiskyExecUsage(riskyExecNode)
// Output the exec usage node with appropriate version-specific warning message
select riskyExecNode, getVersionSpecificExecWarning()