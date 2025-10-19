/**
 * @name Modification of parameter with default value
 * @description Identifies code paths that modify parameters with default values.
 *              Such modifications can cause unexpected behavior because default values
 *              are created only once at function definition time.
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