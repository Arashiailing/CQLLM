/**
 * @name Default Parameter Value Mutation
 * @description Detects mutations of parameters that have default values. Such mutations can cause unexpected behavior because the default value is shared across multiple function calls.
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