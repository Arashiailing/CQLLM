/**
 * @name 'exec' used
 * @description Detects usage of the 'exec' statement or function which may lead to arbitrary code execution.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// Import Python module for code analysis
import python

// Helper function to generate appropriate error message based on Python version
string get_exec_warning_message() {
  // For Python 2, return message about exec statement
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // For Python 3, return message about exec function
  major_version() = 3 and result = "The 'exec' function is used."
}

// Helper predicate to identify calls to the exec function
predicate is_exec_function_call(Call execCallNode) {
  // Check if the call references a global variable named 'exec'
  exists(GlobalVariable execGlobalVar | 
    execGlobalVar = execCallNode.getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  )
}

// Find all exec usage nodes in the AST and return them with corresponding warning message
from AstNode dangerousExecNode
// Filter for either exec function calls or exec statements
where is_exec_function_call(dangerousExecNode) or dangerousExecNode instanceof Exec
// Return the problematic node and corresponding message
select dangerousExecNode, get_exec_warning_message()