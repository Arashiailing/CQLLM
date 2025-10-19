/**
* @name Improper Input Validation
* @description The product receives input or data, but it does
*              not validate or incorrectly validates that the input has the
*              properties that are required to process the data safely and
*              correctly.
* @kind path-problem
* @problem.severity error
* @security-severity 7.8
* @precision high
* @id py/template
* @tags correctness
*       security
*       external/cwe/cwe-20
*/

import python
import semmle.python.security.dataflow.TemplateInjectionQuery
import TemplateInjectionFlow::PathGraph

from TemplateInjectionFlow::PathNode source, TemplateInjectionFlow::PathNode sink
where TemplateInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "This template construction depends on a $@.", source.getNode(), "user-provided value"