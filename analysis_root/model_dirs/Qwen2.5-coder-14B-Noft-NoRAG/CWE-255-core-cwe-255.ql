import python

/**
 * @name CWE-255: Cleartext Storage of Sensitive Information
 * @description Detects the storage of sensitive information in cleartext.
 * @id py/core-cwe-255
 */

from Call call, StringLiteral str
where call.getCallee().getName() = "open" and
      call.getArgument(0) = str and
      str.getValue() matches ".*\\.(txt|csv|log|conf|ini|properties|xml|json)$"
select call, "This call to 'open' may store sensitive information in cleartext."