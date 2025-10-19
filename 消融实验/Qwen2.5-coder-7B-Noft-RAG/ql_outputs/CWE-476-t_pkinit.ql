/**
* @name CWE-476: NULL Pointer Dereference
*
@description The product dereferences a pointer that it expects to be valid but is NULL.
*
@id py/null-pointer-dereference
*/
import python
import semmle.python.security.dataflow.StackTraceExposureQuery
from Call call, Expr expr
    where StackTraceExposureQuery::flowPath(call, expr)
    and expr.isNull()
    select call, "Dereferencing a null pointer can lead to undefined behavior."