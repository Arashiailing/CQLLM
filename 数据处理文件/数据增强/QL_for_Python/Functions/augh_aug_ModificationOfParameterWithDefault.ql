/**
 * @name Modification of parameter with default
 * @description Identifies code paths where parameters with default values are modified,
 *              potentially causing unexpected behavior since default values are initialized
 *              only once during function definition.
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
  ModificationOfParameterWithDefault::Flow::PathNode mutationSource,
  ModificationOfParameterWithDefault::Flow::PathNode mutationSink
where
  ModificationOfParameterWithDefault::Flow::flowPath(mutationSource, mutationSink)
select
  mutationSink.getNode(),
  mutationSource,
  mutationSink,
  "This expression mutates a $@.",
  mutationSource.getNode(),
  "default value"