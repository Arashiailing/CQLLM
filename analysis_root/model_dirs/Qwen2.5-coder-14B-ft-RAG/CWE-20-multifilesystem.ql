/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @id py/multifilesystem
 * @precision low
 * @problem.severity error
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.MultiFilesystemAccessQuery

from MultiFilesystemAccessFlow::PathNode source, MultiFilesystemAccessFlow::PathNode sink
where MultiFilesystemAccessFlow::flowPath(source, sink)
select sink.getNode(),
  source,
  sink,
  "$@ reaches a multi-file system operation.",  
  source.getNode(),  
  "User-provided input"