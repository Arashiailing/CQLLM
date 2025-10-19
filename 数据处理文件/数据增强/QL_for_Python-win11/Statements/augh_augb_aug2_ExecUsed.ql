/**
 * @name 'exec' used
 * @description Identifies instances where the 'exec' statement or function is utilized, potentially leading to arbitrary code execution.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// Import necessary Python analysis library
import python

// Predicate to detect invocations of the exec function
predicate checkForExecFunctionCall(Call functionCallNode) {
  exists(GlobalVariable execVariable | 
    execVariable = functionCallNode.getFunc().(Name).getVariable() and 
    execVariable.getId() = "exec"
  )
}

// Function that returns version-specific warning message for exec usage
string getExecWarningMessage() {
  // Generate appropriate warning based on Python version
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// Primary query: Locate all occurrences of exec usage (either as statement or function call)
from AstNode execUsageInstance
where 
  // Check if the node is an exec function call
  checkForExecFunctionCall(execUsageInstance) 
  or 
  // Check if the node is an exec statement
  execUsageInstance instanceof Exec
select execUsageInstance, getExecWarningMessage()