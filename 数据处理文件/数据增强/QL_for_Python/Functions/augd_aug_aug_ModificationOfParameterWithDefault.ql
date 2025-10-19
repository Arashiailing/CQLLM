/**
 * @name Modification of Parameter with Default Value
 * @description Identifies code that modifies a parameter which has a default value. This can lead to unexpected behavior because the default value is shared across multiple function calls.
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