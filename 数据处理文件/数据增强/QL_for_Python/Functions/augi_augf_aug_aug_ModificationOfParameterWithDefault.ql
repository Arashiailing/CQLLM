/**
 * @name Parameter with default value modification
 * @description Detects modifications of parameters that have default values. Such modifications can cause unexpected behavior because default values are shared across function calls.
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
  ModificationOfParameterWithDefault::Flow::PathNode targetNode
where 
  ModificationOfParameterWithDefault::Flow::flowPath(sourceNode, targetNode)
select 
  targetNode.getNode(), 
  sourceNode, 
  targetNode, 
  "This expression mutates a $@.", 
  sourceNode.getNode(),
  "default value"