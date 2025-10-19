import py

/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detects cleartext storage of sensitive information in Python code.
 */
from StringLiteral sl, FileWrite fw
where sl.value matches /password|secret|token|key|credentials|api|private|confidential|sensitive/
  and fw.content = sl
select fw, "CWE-200: Cleartext storage of sensitive information detected in file write operation"