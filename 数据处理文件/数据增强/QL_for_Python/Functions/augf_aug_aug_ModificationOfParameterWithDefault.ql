/**
 * @name Parameter with default value modification
 * @description Detects modifications of parameters that have default values, which can cause unexpected behavior since default values are shared across function calls.
 * @kind path-problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/modification-of-default-value
 */

import python
import semmle.python.functions.ModificationOfParameterWithDefault
import ModificationOfParameterWithDefault::Flow::PathGraph

from
  ModificationOfParameterWithDefault::Flow::PathNode startNode,
  ModificationOfParameterWithDefault::Flow::PathNode endNode
where 
  ModificationOfParameterWithDefault::Flow::flowPath(startNode, endNode)
select 
  endNode.getNode(), 
  startNode, 
  endNode, 
  "This expression mutates a $@.", 
  startNode.getNode(),
  "default value"