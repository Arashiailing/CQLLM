import python

from AssignmentExpr assign
where assign.rhs.toString() = "False"
and assign.lhs.toString() matches "csrf.*enabled|csrf_protection|csrf_exempt"
select assign

from Call call, StringLiteral sl
where call.getMethodName() = "remove"
and sl.getValue() = "CsrfViewMiddleware"
and call.getArguments() has sl
select call

from FunctionDecl fd
where fd.getDecorators().has("csrf_exempt")
select fd