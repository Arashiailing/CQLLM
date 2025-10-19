/**
 * @name Modification of parameter with default
 * @description Detects code paths where parameters initialized with default values 
 *              are modified. Such modifications can lead to unexpected behavior 
 *              because default values are created only once during function definition,
 *              not per invocation.
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
  ModificationOfParameterWithDefault::Flow::PathNode paramDefaultNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutationNode
where
  ModificationOfParameterWithDefault::Flow::flowPath(paramDefaultNode, mutationNode)
select
  mutationNode.getNode(), 
  paramDefaultNode, 
  mutationNode, 
  "This expression mutates a $@.", 
  paramDefaultNode.getNode(),
  "default value"