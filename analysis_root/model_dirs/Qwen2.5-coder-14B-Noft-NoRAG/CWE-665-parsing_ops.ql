import python

/**
 * This query detects potential CWE-665: Improper Initialization vulnerabilities
 * in Python code. It looks for instances where an object is deserialized without
 * proper initialization.
 */

from DeserializationCall deserializationCall
where not exists(
  InitializationCall initCall |
  initCall.getTarget() = deserializationCall.getTarget() and
  initCall.getASTParent() instanceof ExpressionStatement and
  initCall.getASTParent().getEnclosingBlock() = deserializationCall.getEnclosingBlock()
)
select deserializationCall, "Deserialization call without proper initialization."