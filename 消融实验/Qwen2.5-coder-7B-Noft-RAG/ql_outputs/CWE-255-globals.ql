/**
* @name Cleartext Storage of Sensitive Information
*
@description Storing sensitive information in cleartext may allow attackers to intercept
    and read the data.
* @kind path-problem
* @problem.severity error
* @security-severity 8.0
* @precision high
*
@id py/cleartext-storage
*/
import python
import semmle.python.security.dataflow.SensitiveDataExposureQuery
from DataFlow::Node source, DataFlow::Node sink
    where SensitiveDataExposureQuery::flowPath(source, sink)
    select sink.getNode(), source, sink, "Sensitive information is stored in cleartext.", source.getNode(), "sensitive data"