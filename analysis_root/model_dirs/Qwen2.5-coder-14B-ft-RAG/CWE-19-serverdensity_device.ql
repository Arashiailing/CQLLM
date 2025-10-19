/**
 * @name Command injection via subprocess.Popen
 * @description Calls to Popen can inject commands if they aren't properly sanitized.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/command-injection-popen
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 */

import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Subprocess

from Subprocess::PopenCommandExecution cmdExec, DataFlow::Node badInput, string paramName
where
  // Check if the command execution uses raw strings for command components
  (
    cmdExec.useOfRawString(paramName) = true and
    badInput = cmdExec.getAnExecutionArgument()
  )
  or
  // Handle cases where no parameter name is specified
  (
    not exists(cmdExec.useOfRawString(_)) and
    badInput = cmdExec.getAFlawedArgument()
  )
select cmdExec.getHighlight(), badInput,
  "Creation of this process may depend on a $@.", badInput,
  "potentially unsanitized input"