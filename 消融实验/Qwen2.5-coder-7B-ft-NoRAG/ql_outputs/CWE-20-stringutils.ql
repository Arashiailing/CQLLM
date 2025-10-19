/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 * not validate or incorrectly validates that the input has the
 * properties that are required to process the data safely and
 * correctly.
 * @id py/stringutils
 */

import python
import semmle.python.security.dataflow.InsecureStringMethodQuery
import InsecureStringMethodFlow::PathGraph

from InsecureStringMethodFlow::PathNode source, InsecureStringMethodFlow::PathNode sink
where InsecureStringMethodFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Insecure string method call depends on a $@.", source.getNode(), "user-supplied input"