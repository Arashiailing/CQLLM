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

// Import the Python library for code analysis and AST traversal
import python

// Helper function to generate version-specific warning messages for exec usage
string generateExecWarningMessage() {
  // For Python 2, where exec is a statement
  result = "The 'exec' statement is used." and major_version() = 2
  // For Python 3, where exec is a function
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// Main query to identify all instances of exec usage in the code
from AstNode riskyExecNode
// Check if the node represents either an exec function call or an exec statement
where 
  exists(GlobalVariable execGlobalVar | 
    riskyExecNode instanceof Call and
    execGlobalVar = riskyExecNode.(Call).getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  ) 
  or 
  riskyExecNode instanceof Exec
// Output the identified exec usage node with the appropriate warning message
select riskyExecNode, generateExecWarningMessage()