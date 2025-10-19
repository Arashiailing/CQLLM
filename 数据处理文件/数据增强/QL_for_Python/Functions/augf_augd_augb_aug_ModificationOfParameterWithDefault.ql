/**
 * @name Modification of Parameter with Default Value
 * @description Identifies code paths where parameters initialized with default values 
 *              are subsequently modified. This pattern can cause unexpected behavior 
 *              because default values are created only once during function definition.
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
  ModificationOfParameterWithDefault::Flow::PathNode defaultValueSource,
  ModificationOfParameterWithDefault::Flow::PathNode mutationTarget
where
  ModificationOfParameterWithDefault::Flow::flowPath(defaultValueSource, mutationTarget)
select
  mutationTarget.getNode(), 
  defaultValueSource, 
  mutationTarget, 
  "This expression modifies a $@.", 
  defaultValueSource.getNode(),
  "parameter with default value"