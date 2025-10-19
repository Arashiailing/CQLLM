/**
 * @name Modification of parameter with default value
 * @description Detects code paths that modify parameters with default values.
 *              Such modifications can lead to unexpected behavior because default values
 *              are created only once during function definition.
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