/**
 * @name Modification of parameter with default
 * @description Identifies code paths where parameters initialized with default values are modified.
 *              Such modifications can cause unexpected behavior since default values are instantiated
 *              only once during function definition, not per function call.
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
  ModificationOfParameterWithDefault::Flow::PathNode defaultValueNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutationNode
where
  ModificationOfParameterWithDefault::Flow::flowPath(defaultValueNode, mutationNode)
select
  mutationNode.getNode(), 
  defaultValueNode, 
  mutationNode, 
  "This expression mutates a $@.", 
  defaultValueNode.getNode(),
  "default value"