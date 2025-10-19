/**
 * @name Code injection
 * @description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary
 *              code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @sub-severity high
 * @precision high
 * @id py/evaluator
 * @tags security
 *       external/cwe/cwe-094
 *       external/cwe/cwe-095
 *       external/cwe/cwe-116
 */

import python
import semmle.python.ApiGraphs

from Class evalClass, string methodName, API::CallNode call, int argIndex
where
  (
    evalClass = API::moduleImport("builtins").getMember("eval")
    or
    exists(string name | name in ["exec", "__import__"] |
      evalClass = API::moduleImport(name).getMember("__call__")
    )
  ) and
  call = evalClass.getACall() and
  methodName = call.getFunction().(Attribute).getName() and
  argIndex = if methodName = "__import__" then 0 else 1
select call,
  "Call to deprecated function " + methodName +
    " may be insecure because it depends on a $@.", call.getArg(argIndex),
  call.getArg(argIndex).describe()