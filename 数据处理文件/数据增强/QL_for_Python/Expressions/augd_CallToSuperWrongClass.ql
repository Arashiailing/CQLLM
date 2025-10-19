/**
 * @name First argument to super() is not enclosing class
 * @description Calling super with something other than the enclosing class may cause incorrect object initialization.
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

// Identify super() calls where the first argument doesn't match the enclosing class name
from DataFlow::CallCfgNode superInvocation, string enclosingClassName
where
  // Locate calls to the built-in super() function
  superInvocation = API::builtin("super").getACall() and
  // Extract the name of the class containing the super() call
  enclosingClassName = superInvocation.getScope().getScope().(Class).getName() and
  // Verify the first argument exists and doesn't match the enclosing class
  exists(DataFlow::Node firstArg |
    firstArg = superInvocation.getArg(0) and
    // Compare the argument's identifier with the enclosing class name
    firstArg.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
// Report the problematic super() call with expected class name
select superInvocation.getNode(), "First argument to super() should be " + enclosingClassName + "."