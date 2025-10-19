/**
 * @name First argument to super() is not enclosing class
 * @description Identifies super() invocations where the first parameter does not match
 *              the containing class, potentially causing improper object initialization.
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

from DataFlow::CallCfgNode superCall, string containingClassName
where
  // Locate all super() function calls in the codebase
  superCall = API::builtin("super").getACall() and
  // Extract the name of the class that contains the super() invocation
  containingClassName = superCall.getScope().getScope().(Class).getName() and
  // Verify that a first argument exists and does not match the enclosing class
  exists(DataFlow::Node initialParam |
    initialParam = superCall.getArg(0) and
    // Compare the argument's identifier against the containing class name
    initialParam.getALocalSource().asExpr().(Name).getId() != containingClassName
  )
select superCall.getNode(), 
       "First argument to super() should be " + containingClassName + "."