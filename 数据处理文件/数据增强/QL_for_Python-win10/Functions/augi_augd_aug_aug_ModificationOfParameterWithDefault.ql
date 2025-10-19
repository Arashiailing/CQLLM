/**
 * @name Modification of Parameter with Default Value
 * @description Detects code that modifies a parameter with a default value. This can cause unexpected behavior because the default value is shared across multiple function calls.
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
  ModificationOfParameterWithDefault::Flow::PathNode sourceNode,
  ModificationOfParameterWithDefault::Flow::PathNode sinkNode
where 
  ModificationOfParameterWithDefault::Flow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "This expression mutates a $@.", 
  sourceNode.getNode(),
  "default value"