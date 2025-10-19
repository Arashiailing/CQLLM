/**
 * @name CWE-862: Missing Authorization
 * @description The product does not perform an authorization check when an actor attempts to access a resource or perform an action.
 * @kind problem
 * @id py/invite
 */

import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode func, string className, string methodName
where
  (
    func = API::moduleImport("flask").getMember("Flask").getReturn().getASubScope().getAnAccess()
    and
    className = "Flask"
    and
    methodName = "route"
  )
  or
  (
    func = API::moduleImport("django").getMember("urls").getMember("path").getReturn().getASubScope().getAnAccess()
    and
    className = "Django"
    and
    methodName = "url"
  )
select func,
  "The " + className + " function '" + methodName + "' is being called with no authorization guard."