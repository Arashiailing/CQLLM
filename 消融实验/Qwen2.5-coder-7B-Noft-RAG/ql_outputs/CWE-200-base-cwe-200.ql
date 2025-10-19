/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@id py/base-cwe-200
*/
import python class CleartextLogging extends Call { CleartextLogging() { this.getFunction().getName() in {"print", "logging.debug", "logging.info"} } }
from CleartextLogging cleartextLogging, String message
    where cleartextLogging.getArgument(0) = message
    select cleartextLogging, "Sensitive information is logged in cleartext."