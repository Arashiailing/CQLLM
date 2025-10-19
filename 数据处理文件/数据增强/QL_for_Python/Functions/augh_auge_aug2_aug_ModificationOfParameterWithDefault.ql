/**
 * @name Modification of parameter with default value
 * @description Identifies code paths where parameters with default values are modified.
 *              Such modifications cause unexpected behavior since default values
 *              are instantiated only once during function definition.
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
  ModificationOfParameterWithDefault::Flow::PathNode initialDefaultNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutatingNode
where
  ModificationOfParameterWithDefault::Flow::flowPath(initialDefaultNode, mutatingNode)
select
  mutatingNode.getNode(), 
  initialDefaultNode, 
  mutatingNode, 
  "This expression mutates a $@.", 
  initialDefaultNode.getNode(),
  "default value"