/**
 * @name CWE-863: Incorrect Authorization
 * @description The product performs an authorization check when an actor attempts to access a resource or perform an action, but it does not correctly perform the check.
 * @id py/streams
 */
import python
import semmle.python.security.authorization.AuthorizationQuery

predicate incorrectAuthorizationCheck(MethodCallNode call) {
  exists(Method method | method = call.getMethod() and
    method.getName() = "check_authorization" and
    not AuthorizationQuery::isCorrectAuthorizationCheck(method)
  )
}

from MethodCallNode call
where incorrectAuthorizationCheck(call)
select call, "This method call performs an incorrect authorization check."