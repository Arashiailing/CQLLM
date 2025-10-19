/**
 * @name 'exec' used
 * @description Identifies instances where the 'exec' statement or function is utilized, potentially enabling arbitrary code execution.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// Import the Python module for static code analysis
import python

// Function that returns a version-specific warning message for exec usage
string get_exec_warning_message() {
  // Generate message for Python 2 regarding exec statement
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // Generate message for Python 3 regarding exec function
  major_version() = 3 and result = "The 'exec' function is used."
}

// Predicate that detects invocations of the exec function
predicate is_exec_function_call(Call execInvocation) {
  // Verify if the call targets a global variable with the name 'exec'
  exists(GlobalVariable execGlobalVariable | 
    execGlobalVariable = execInvocation.getFunc().(Name).getVariable() and 
    execGlobalVariable.getId() = "exec"
  )
}

// Query that locates all exec-related nodes in the AST and reports them with appropriate warnings
from AstNode execUsageNode
// Filter to include either exec function calls or exec statements
where is_exec_function_call(execUsageNode) or execUsageNode instanceof Exec
// Output the identified node along with its corresponding warning message
select execUsageNode, get_exec_warning_message()