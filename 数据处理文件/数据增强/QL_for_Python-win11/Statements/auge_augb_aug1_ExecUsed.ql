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

// Function that constructs a version-specific warning message for exec usage
string generate_exec_alert() {
  // Python 2 uses exec statement
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  // Python 3 uses exec function
  major_version() = 3 and result = "The 'exec' function is used."
}

// Predicate that identifies invocations of the exec function
predicate exec_function_invocation(Call functionCall) {
  // Verify the call targets a global variable named 'exec'
  exists(GlobalVariable globalExecRef | 
    globalExecRef = functionCall.getFunc().(Name).getVariable() and 
    globalExecRef.getId() = "exec"
  )
}

// Main query to detect all exec usage patterns in the codebase
from AstNode execUsageNode
// Match either exec function calls or exec statements
where exec_function_invocation(execUsageNode) or execUsageNode instanceof Exec
// Output the detected node with appropriate warning message
select execUsageNode, generate_exec_alert()