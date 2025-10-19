/**
 * @name Modification of parameter with default
 * @description Detects code paths where parameters initialized with default values 
 *              are modified after function definition. This can lead to unexpected 
 *              behavior since default values are created once during function 
 *              definition, not per function call.
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
  ModificationOfParameterWithDefault::Flow::PathNode defaultValueNode,  // Default value parameter node
  ModificationOfParameterWithDefault::Flow::PathNode modificationNode    // Modification point node
where
  ModificationOfParameterWithDefault::Flow::flowPath(defaultValueNode, modificationNode)
select
  modificationNode.getNode(), 
  defaultValueNode, 
  modificationNode, 
  "This expression mutates a $@.", 
  defaultValueNode.getNode(),
  "default value"