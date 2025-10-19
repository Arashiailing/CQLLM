/**
 * @name Default Parameter Value Mutation
 * @description Detects mutations of parameters with default values. Such mutations cause unexpected behavior 
 *              because the default value object is shared across multiple function calls, leading to 
 *              state persistence where each call sees modifications from previous invocations.
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