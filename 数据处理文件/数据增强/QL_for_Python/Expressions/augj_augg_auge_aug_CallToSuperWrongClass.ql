/**
 * @name Incorrect super() first argument
 * @description Detects super() calls using a non-enclosing class as the first argument,
 *              which may cause improper initialization and inheritance problems.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 *       external/cwe/cwe-687
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/super-not-enclosing-class
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode superInvocation, string expectedClassName
where
  // Locate all super() function calls
  superInvocation = API::builtin("super").getACall() and
  // Determine the enclosing class name where super() is invoked
  expectedClassName = superInvocation.getScope().getScope().(Class).getName() and
  // Validate the first argument is not the expected class
  exists(DataFlow::Node firstArgument |
    firstArgument = superInvocation.getArg(0) and
    firstArgument.getALocalSource().asExpr().(Name).getId() != expectedClassName
  )
select superInvocation.getNode(), "First argument to super() should be " + expectedClassName + "."