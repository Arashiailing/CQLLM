import python
import semmle.python.security.dataflow.XxeQuery

/**
 * This query detects potential XXE vulnerabilities in Python code.
 * It looks for calls to XML parsing functions that do not disable external entity expansion.
 */

from XxeQuery::XxeSink sink
select sink, "This XML parsing call may be vulnerable to XXE attacks because external entity expansion is not disabled."