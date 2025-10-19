/**
 * @name Modification of parameter with default
 * @description Detects code paths where parameters with default values are modified.
 *              Such modifications can cause unexpected behavior because default values
 *              are instantiated only once during function definition, not per call.
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