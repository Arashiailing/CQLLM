import python

/**
 * CWE-264: Cleartext Storage
 * This query detects instances where sensitive data is stored in cleartext.
 */

from DataFlow::Node src, DataFlow::Node sink
where src instanceof SensitiveData and sink instanceof FileWrite
  and DataFlow::flowsTo(src, sink)
select sink, "Sensitive data is being written to a file in cleartext."