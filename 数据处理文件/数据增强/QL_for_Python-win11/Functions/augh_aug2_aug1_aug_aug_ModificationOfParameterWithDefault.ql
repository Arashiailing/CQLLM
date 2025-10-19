/**
 * @name Default Parameter Mutations Detection
 * @description Identifies mutations of parameters initialized with default values. 
 *              Such mutations cause unexpected behavior due to shared mutable state 
 *              across function invocations.
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
  ModificationOfParameterWithDefault::Flow::PathNode defaultParameterNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutationNode
where 
  ModificationOfParameterWithDefault::Flow::flowPath(defaultParameterNode, mutationNode)
select 
  mutationNode.getNode(), 
  defaultParameterNode, 
  mutationNode, 
  "This expression mutates a $@.", 
  defaultParameterNode.getNode(),
  "default value"