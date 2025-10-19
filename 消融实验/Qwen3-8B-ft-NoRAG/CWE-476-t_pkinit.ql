import semmle.python.PyCall

from AttrAccess a
where a.get_expr() is e
and PyCall::is_null(e)
select a, "Potential NULL Pointer Dereference"

from MethodCall m
where m.get_expr() is e
and PyCall::is_null(e)
select m, "Potential NULL Pointer Dereference"