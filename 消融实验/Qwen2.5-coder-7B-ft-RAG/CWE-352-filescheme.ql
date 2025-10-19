/**
 * @name Files scheme URL redirection
 * @description Redirects to URLs containing the files scheme are dangerous as they could reveal internal filesystem structure.
 * @kind problem
 * @problem.severity warning
 * @security-severity 6.1
 * @precision medium
 * @id py/filescheme
 * @tags security
 *       external/cwe/cwe-208
 */

import python
import semmle.python.Concepts
import semmle.python.security.dataflow.FilesSchemeRedirectQuery
import FilesSchemeRedirectFlow::PathGraph

from FilesSchemeRedirectFlow::PathNode source, FilesSchemeRedirectFlow::PathNode sink
where FilesSchemeRedirectFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This redirect uses a $@.", source.getNode(), "user-controlled URL"