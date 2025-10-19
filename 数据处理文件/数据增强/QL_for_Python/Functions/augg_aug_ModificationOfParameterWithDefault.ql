/**
 * @name Modification of parameter with default
 * @description Identifies code paths where parameters initialized with default values 
 *              are modified after function definition. This can cause unexpected 
 *              behavior because default values are created once during function 
 *              definition, not on each function call.
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