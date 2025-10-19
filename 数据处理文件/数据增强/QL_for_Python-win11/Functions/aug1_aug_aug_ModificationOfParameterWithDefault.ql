/**
 * @name Default Parameter Mutation Detection
 * @description Identifies modifications to parameters initialized with default values, which may lead to unexpected behavior due to shared mutable state across function invocations.
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
  ModificationOfParameterWithDefault::Flow::PathNode paramDefNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutationNode
where 
  ModificationOfParameterWithDefault::Flow::flowPath(paramDefNode, mutationNode)
select 
  mutationNode.getNode(), 
  paramDefNode, 
  mutationNode, 
  "This expression mutates a $@.", 
  paramDefNode.getNode(),
  "default value"