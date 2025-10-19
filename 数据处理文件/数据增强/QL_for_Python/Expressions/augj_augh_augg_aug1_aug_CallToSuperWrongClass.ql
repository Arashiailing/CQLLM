/**
 * @name Misaligned super() first parameter
 * @description Identifies super() function calls where the initial parameter does not match
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

from DataFlow::CallCfgNode superCall, string enclosingClassName
where
  // Locate all invocations of the built-in super() function
  superCall = API::builtin("super").getACall() and
  // Obtain the name of the class that encloses this super() call
  enclosingClassName = superCall.getScope().getScope().(Class).getName() and
  // Verify the super() call has a first argument
  exists(DataFlow::Node firstArg |
    firstArg = superCall.getArg(0) and
    // Confirm the first argument differs from the enclosing class name
    firstArg.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
select superCall.getNode(), "First argument to super() should be " + enclosingClassName + "."