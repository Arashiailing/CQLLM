/**
 * @name Weak hashing of sensitive data
 * @description The use of broken cryptographic hashes can compromise the security of data protected by those hashes.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/weak-sensitive-data-hashing
 * @tags security
 *       external/cwe/cwe-310
 */

import python
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking

class Source extends DataFlow::Node {
  Source() {
    unsafe_hashing_source(_, this)
  }
}

class Sink extends DataFlow::Node {
  Sink() {
    unsafe_hashing_sink(this, _)
  }
}

from Source source, Sink sink
where TaintTracking::localFlowPath(source, sink)
select sink.getNode(),
  source,
  sink,
  "This $@ operation uses a broken cryptographic hash function.",  
  source,
  "hash"