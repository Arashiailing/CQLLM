/**
 * @name CWE-787: Out-of-bounds Write
 * @description The product writes data past the end, or before the beginning, of the intended buffer.
 * @id py/gperf_unfold_key_conv
 */

import python
import semmle.python.security.dataflow.CodeInjectionQuery

from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
where CodeInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Out-of-bounds write detected.", source.getNode(), "user-provided value"