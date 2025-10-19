import python

/**
 * @name CSRF protection weakened or disabled
 * @description Disabling or weakening CSRF protection may make the application vulnerable to a Cross-Site Request Forgery (CSRF) attack.
 * @id py/filescheme
 */

// Query for disabling CSRF protection in Flask applications
from ConfigValueAssignment assign
where assign.getAssignee().getName() = "WTF_CSRF_ENABLED"
  and assign.getValue().getLiteral().getValue() = "False"
select assign, "CSRF protection is explicitly disabled in Flask configuration"

// Query for using unsafe redirect with user-controlled input in Flask applications
from CallExpr call
where call.getCallee().getName() = "redirect"
  and call.getArg(0).getType().isString()
  and call.getArg(0).getExpression().isUserInput()
select call, "Potential URL redirection with untrusted input"

// Query for bypassing CSRF protection via decorators in Django applications
from DecoratorDecl dec
where dec.getName() = "csrf_exempt"
select dec, "CSRF protection bypassed using csrf_exempt decorator"