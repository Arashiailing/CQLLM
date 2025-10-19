import python

/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detects the storage of sensitive information in cleartext.
 * @id py/keycloak_cli
 */

from FunctionCall call, StringLiteral str
where call.getCallee().getName() = "open" and
      call.getArgument(0) = str and
      str.getValue().matches(".*\\.(txt|log|json|xml|csv)$")
select call, "This function call opens a file that may store sensitive information in cleartext."