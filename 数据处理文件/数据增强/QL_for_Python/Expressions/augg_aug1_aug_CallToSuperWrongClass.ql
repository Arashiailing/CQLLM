/**
 * @name Incorrect first argument in super() call
 * @description Identifies super() calls where the first argument doesn't match the enclosing class,
 *              potentially causing improper object initialization.
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

from DataFlow::CallCfgNode superCall, string enclosingClassName
where
  // Verify the node represents a super() function call
  superCall = API::builtin("super").getACall() and
  // Retrieve the name of the enclosing class
  enclosingClassName = superCall.getScope().getScope().(Class).getName() and
  // Check if first argument exists and doesn't match enclosing class
  exists(DataFlow::Node firstArg |
    firstArg = superCall.getArg(0) and
    // Compare argument identifier with enclosing class name
    firstArg.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
select superCall.getNode(), "First argument to super() should be " + enclosingClassName + "."