/**
 * @name First argument to super() is not enclosing class
 * @description Detects super() calls where the first argument is not the enclosing class,
 *              which may lead to incorrect object initialization.
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

from DataFlow::CallCfgNode superInvocation, string enclosingClass
where
  // Identify super() calls in the code
  superInvocation = API::builtin("super").getACall() and
  // Extract the enclosing class name through scope traversal
  enclosingClass = superInvocation.getScope().getScope().(Class).getName() and
  // Verify first argument exists and doesn't match the enclosing class
  exists(DataFlow::Node firstArgument |
    firstArgument = superInvocation.getArg(0) and
    // Compare argument identifier against enclosing class name
    firstArgument.getALocalSource().asExpr().(Name).getId() != enclosingClass
  )
select superInvocation.getNode(), 
       "First argument to super() should be " + enclosingClass + "."