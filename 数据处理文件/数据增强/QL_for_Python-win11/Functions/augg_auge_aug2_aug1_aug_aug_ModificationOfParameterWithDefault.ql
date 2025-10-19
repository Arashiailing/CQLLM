/**
 * @name Default Parameter Mutation Detection
 * @description Detects mutations of parameters initialized with default values, 
 *              which may cause unexpected behavior due to shared mutable state 
 *              across multiple function invocations.
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
  ModificationOfParameterWithDefault::Flow::PathNode modificationPoint
where 
  ModificationOfParameterWithDefault::Flow::flowPath(defaultValueNode, modificationPoint)
select 
  modificationPoint.getNode(), 
  defaultValueNode, 
  modificationPoint, 
  "This expression mutates a $@.", 
  defaultValueNode.getNode(),
  "default value"