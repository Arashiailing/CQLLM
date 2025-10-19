import python

from PyCall call
where call.getFunction().isRaiseable()
and not call.hasAncestor(PyTry)
select call, "Potential CWE-254: This function call may raise an exception but is not enclosed within a try block."

from PyCall call
where call.getFunction().isRaiseable()
and call.hasAncestor(PyTry)
let tryBlock = call.getAncestors(PyTry).head()
let excepts = tryBlock.getChildren().filter(e | e.getKind() == "PyExcept")
where excepts.size() == 0
select call, "Potential CWE-254: This function call may raise an exception, but the surrounding try block lacks except handlers."