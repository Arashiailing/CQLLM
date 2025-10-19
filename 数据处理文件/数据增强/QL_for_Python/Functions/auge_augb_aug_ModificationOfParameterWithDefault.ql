/**
 * @name Modification of parameter with default
 * @description Detects code paths where parameters with default values are modified.
 *              Such modifications can cause unexpected behavior because default values
 *              are instantiated only once during function definition.
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
  ModificationOfParameterWithDefault::Flow::PathNode paramDefNode,
  ModificationOfParameterWithDefault::Flow::PathNode modificationNode
where
  ModificationOfParameterWithDefault::Flow::flowPath(paramDefNode, modificationNode)
select
  modificationNode.getNode(), 
  paramDefNode, 
  modificationNode, 
  "This expression mutates a $@.", 
  paramDefNode.getNode(),
  "default value"