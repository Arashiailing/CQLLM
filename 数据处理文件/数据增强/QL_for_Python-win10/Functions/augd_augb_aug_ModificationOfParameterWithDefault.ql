/**
 * @name Modification of Parameter with Default Value
 * @description Detects code paths where parameters with default values are modified.
 *              Modifying default values can lead to unexpected behavior since they are
 *              instantiated only once when the function is defined.
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
  ModificationOfParameterWithDefault::Flow::PathNode defValSourceNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutationTargetNode
where
  ModificationOfParameterWithDefault::Flow::flowPath(defValSourceNode, mutationTargetNode)
select
  mutationTargetNode.getNode(), 
  defValSourceNode, 
  mutationTargetNode, 
  "This expression mutates a $@.", 
  defValSourceNode.getNode(),
  "default value"