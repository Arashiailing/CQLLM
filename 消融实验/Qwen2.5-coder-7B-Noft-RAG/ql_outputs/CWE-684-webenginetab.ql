/**
* @name CWE-684: Incorrect Provision of Specified Functionality
*
@id py/webenginetab
*/
import python
from Call call, Expr expr
    where call.getTarget().getName() = "redirect"
    and call.getParent().isA(MethodCall)
    select call, "Incorrect provision of specified functionality through redirect method."