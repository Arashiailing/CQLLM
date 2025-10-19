/**
* @name Unvalidated return data
* @description The product returns user input without validating or escaping the data,
* creating potential vulnerabilities for injection attacks.
* @kind path-problem
* @problem.severity error
* @security-severity 7.8
* @precision medium
* @id py/unvalidated-return-data
* @tags security
*       external/cwe/cwe-20
*/

import python
import semmle.python.security.dataflow.UnvalidatedReturnDataQuery
import UnvalidatedReturnDataFlow::PathGraph

from
  UnvalidatedReturnDataFlow::PathNode source, UnvalidatedReturnDataFlow::PathNode sink
where
  UnvalidatedReturnDataFlow::flowPath(source, sink)
select
  sink.getNode(), source, sink, "This unvalidated return statement incorporates a $@.",
  source.getNode(), "user-provided value"