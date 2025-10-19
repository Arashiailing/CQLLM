/**
 * @name Incorrect super() first argument
 * @description The first argument to super() should be the enclosing class. Using a different class
 *              can cause improper object initialization and inheritance problems.
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

from DataFlow::CallCfgNode superInvocation, string currentClassName
where
  // Identify all calls to the built-in super() function
  superInvocation = API::builtin("super").getACall() and
  // Extract the name of the enclosing class where super() is called
  currentClassName = superInvocation.getScope().getScope().(Class).getName() and
  // Verify that super() has a first argument that is not the enclosing class
  exists(DataFlow::Node firstArgument |
    firstArgument = superInvocation.getArg(0) and
    // Compare the identifier of the first argument with the enclosing class name
    firstArgument.getALocalSource().asExpr().(Name).getId() != currentClassName
  )
select superInvocation.getNode(), "First argument to super() should be " + currentClassName + "."