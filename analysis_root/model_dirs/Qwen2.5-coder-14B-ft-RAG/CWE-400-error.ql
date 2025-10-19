/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/uncontrolled-resource-consumption
 * @tags security
 *       external/cwe/cwe-400
 */

import python
import semmle.python.Concepts
import FluentApiConcepts

from
  ApiConsumedWithUncontrolledData ucd,
  ApiExecution exec
where
  exec = ucd.getAnExecution()
select exec, ucd.describe()