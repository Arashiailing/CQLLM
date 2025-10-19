/**
* @name CWE-665: Improper Initialization
*
@description nan
*
@id py/parsing_ops
*/
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
from Call c, string mod, string function
    where mod = "pickle"
    and function = "loads"
    and c.getTarget().isReferringTo(API::moduleImport(mod).getMember(function))
    select c, "Call to deprecated function " + mod + "." + function + " may be insecure."