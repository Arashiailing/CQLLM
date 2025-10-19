/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @id py/0002_auto_20190406_1322
 */
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.security.dataflow.SecretHandling

from DataFlow::Node source, DataFlow::Node sink
where SecretHandling::isSecret(source) and
      DataFlow::pathExists(source, sink) and
      sink.getType().getName() = "str" and
      sink.isAssignedTo("file") or
      sink.isAssignedTo("database")
select sink, source, "Sensitive credentials stored in cleartext."