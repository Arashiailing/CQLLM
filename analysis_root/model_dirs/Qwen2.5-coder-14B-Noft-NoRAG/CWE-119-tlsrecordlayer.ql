import python

/**
 * Detects CWE-119: Unsafe Deserialization vulnerability.
 */
from Call call, Deserialization deserialization
where call.getCallee() = deserialization
select call, "This call to " + call.getCallee().getName() + " may lead to unsafe deserialization."