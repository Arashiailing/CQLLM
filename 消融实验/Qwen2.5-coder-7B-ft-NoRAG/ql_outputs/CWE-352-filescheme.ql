/**
 * @name Filescheme URL detected
 * @description Detects URLs with 'file://' scheme which can lead to local file inclusion vulnerabilities.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/filescheme
 * @tags security
 */

import python
import semmle.python.security.dataflow.FileschemeUrlQuery

from FileschemeUrlFlow::PathNode source, FileschemeUrlFlow::PathNode sink
where FileschemeUrlFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Filescheme URL detected which can lead to local file inclusion vulnerabilities.", source.getNode(), "user-provided value"