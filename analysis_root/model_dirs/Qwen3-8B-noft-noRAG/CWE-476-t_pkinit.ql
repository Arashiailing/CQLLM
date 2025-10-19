import python

/**
 * @name CWE-476: NULL Pointer Dereference
 * @description The product dereferences a pointer that it expects to be valid but is NULL.
 */

from CallSite cs, MethodCall mc, AssignExpr ae
where cs.getKind() = "call" and
      mc = cs.getMethodCall() and
      ae = mc.getBaseExpression() and
      exists( (ae as VarDecl).getInit() as AssignExpr where getAssignValue().isNone() )
select ae.getLocation(), "Potential NULL pointer dereference: variable may be None before method call"