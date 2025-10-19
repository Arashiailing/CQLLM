/**
 * @name Modification of parameter with default
 * @description Detects code paths where parameters with default values are modified,
 *              which can lead to unexpected behavior since default values are created
 *              only once when the function is defined.
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
  ModificationOfParameterWithDefault::Flow::PathNode startNode,
  ModificationOfParameterWithDefault::Flow::PathNode endNode
where
  ModificationOfParameterWithDefault::Flow::flowPath(startNode, endNode)
select
  endNode.getNode(), 
  startNode, 
  endNode, 
  "This expression mutates a $@.", 
  startNode.getNode(),
  "default value"