/**
 * @name Default Parameter Value Mutation
 * @description Identifies mutations of parameters with default values. 
 * Such mutations cause unexpected behavior because the default value 
 * is shared across multiple function calls.
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
  ModificationOfParameterWithDefault::Flow::PathNode defaultNode,
  ModificationOfParameterWithDefault::Flow::PathNode mutationNode
where 
  ModificationOfParameterWithDefault::Flow::flowPath(defaultNode, mutationNode)
select 
  mutationNode.getNode(), 
  defaultNode, 
  mutationNode, 
  "This expression mutates a $@.", 
  defaultNode.getNode(),
  "default value"