/**
 * @name 'exec' used
 * @description Detects usage of 'exec' statement or function, which can lead to arbitrary code execution.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// Import Python library for analyzing Python code
import python

// Generate appropriate warning message based on Python version
string getAlertMessage() {
  // Check Python major version and return corresponding warning text
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Main query: Find all code nodes using exec statement or function
from AstNode riskyExecNode
// Filter conditions: Node is either an exec function call or an exec statement
where 
  // Check if node is an exec statement
  riskyExecNode instanceof Exec
  or
  // Check if node is an exec function call
  exists(GlobalVariable execGlobalVar | 
    riskyExecNode instanceof Call and
    execGlobalVar = riskyExecNode.(Call).getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  )
// Return detection result and corresponding warning message
select riskyExecNode, getAlertMessage()