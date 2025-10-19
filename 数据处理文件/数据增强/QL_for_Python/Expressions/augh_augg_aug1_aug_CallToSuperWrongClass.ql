/**
 * @name Incorrect first argument in super() call
 * @description Detects instances where super() is called with a first argument that does not
 *              correspond to the enclosing class, which may lead to incorrect object initialization.
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

from DataFlow::CallCfgNode superInvocation, string parentClassName
where
  // Identify calls to the built-in super() function
  superInvocation = API::builtin("super").getACall() and
  // Extract the name of the class that contains this super() call
  parentClassName = superInvocation.getScope().getScope().(Class).getName() and
  // Ensure there is a first argument to the super() call
  exists(DataFlow::Node initialArgument |
    initialArgument = superInvocation.getArg(0) and
    // Validate that the first argument does not match the enclosing class name
    initialArgument.getALocalSource().asExpr().(Name).getId() != parentClassName
  )
select superInvocation.getNode(), "First argument to super() should be " + parentClassName + "."