/**
 * @name Incorrect super() first argument
 * @description Passing a non-enclosing class as the first argument to super() 
 * can lead to improper object initialization in Python class hierarchies.
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
  // Identify all super() calls in the codebase
  superInvocation = API::builtin("super").getACall()
  // Retrieve the name of the class containing the super() call
  and currentClassName = superInvocation.getScope().getScope().(Class).getName()
  // Validate the first argument exists and is not the enclosing class
  and exists(DataFlow::Node superFirstArg |
    superFirstArg = superInvocation.getArg(0)
    and superFirstArg.getALocalSource().asExpr().(Name).getId() != currentClassName
  )
select superInvocation.getNode(), 
  "First argument to super() should be the enclosing class '" + currentClassName + "'."