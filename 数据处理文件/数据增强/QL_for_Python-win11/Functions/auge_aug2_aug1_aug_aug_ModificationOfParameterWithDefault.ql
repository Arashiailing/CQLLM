/**
 * @name Default Parameter Mutation Detection
 * @description Identifies mutations of parameters initialized with default values, 
 *              which can lead to unexpected behavior due to shared mutable state 
 *              across multiple function invocations.
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
  ModificationOfParameterWithDefault::Flow::PathNode defaultParamNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutationNode
where 
  ModificationOfParameterWithDefault::Flow::flowPath(defaultParamNode, mutationNode)
select 
  mutationNode.getNode(), 
  defaultParamNode, 
  mutationNode, 
  "This expression mutates a $@.", 
  defaultParamNode.getNode(),
  "default value"