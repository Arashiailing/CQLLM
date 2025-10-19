import python

/**
 * Detects potential CWE-20: Unsafe Deserialization vulnerabilities.
 */
from DeserializationCall call
where not exists(call.getArgument(0).getAExpr().getASubscriptExpr())
select call, "This deserialization call does not validate the input data."