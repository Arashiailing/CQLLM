/**
 * @name Incorrect first argument to super()
 * @description The first argument to super() should be the enclosing class. Using a different class may lead to incorrect object initialization.
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

// Identify super() calls and their enclosing class context
from DataFlow::CallCfgNode superInvocation, string enclosingClass
where
  // Locate calls to the built-in super() function
  superInvocation = API::builtin("super").getACall()
  // Extract the name of the class where super() is called
  and enclosingClass = superInvocation.getScope().getScope().(Class).getName()
  // Verify the first argument exists and differs from the enclosing class
  and exists(DataFlow::Node initialArg |
    initialArg = superInvocation.getArg(0)
    // Ensure the argument's source identifier doesn't match the enclosing class
    and initialArg.getALocalSource().asExpr().(Name).getId() != enclosingClass
  )
// Report the problematic super() call with expected class name
select superInvocation.getNode(), 
       "First argument to super() should be " + enclosingClass + "."