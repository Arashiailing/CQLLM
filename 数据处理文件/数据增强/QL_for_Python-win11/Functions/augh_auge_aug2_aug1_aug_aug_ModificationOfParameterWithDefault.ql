/**
 * @name Default Parameter Mutation Detection
 * @description Detects mutations of parameters initialized with default values. 
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
  ModificationOfParameterWithDefault::Flow::PathNode defaultValueNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutationPointNode
where 
  ModificationOfParameterWithDefault::Flow::flowPath(defaultValueNode, mutationPointNode)
select 
  mutationPointNode.getNode(), 
  defaultValueNode, 
  mutationPointNode, 
  "This expression mutates a $@.", 
  defaultValueNode.getNode(),
  "default value"