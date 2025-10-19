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
 * @id py/use-of-exec */

// Import Python module for code analysis
import python

// Helper function to generate version-specific warning message for exec usage
string get_exec_warning_message() {
  // Return message for Python 2 exec statement
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // Return message for Python 3 exec function
  major_version() = 3 and result = "The 'exec' function is used."
}

// Helper predicate to identify calls to the exec function
predicate is_exec_function_call(Call execFuncCallNode) {
  // Check if call references global variable named 'exec'
  exists(GlobalVariable execGlobalVariable | 
    execGlobalVariable = execFuncCallNode.getFunc().(Name).getVariable() and 
    execGlobalVariable.getId() = "exec"
  )
}

// Identify all exec usage nodes (function calls or statements)
from AstNode execUsageNode
where 
  // Check for exec function calls
  exists(Call funcCall | 
    is_exec_function_call(funcCall) and 
    funcCall = execUsageNode
  )
  or
  // Check for exec statements
  execUsageNode instanceof Exec
// Return problematic node and corresponding warning message
select execUsageNode, get_exec_warning_message()