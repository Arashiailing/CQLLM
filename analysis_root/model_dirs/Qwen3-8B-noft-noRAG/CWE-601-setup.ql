import python

from Call call, StringParam param
where call.getTarget().getName() = "redirect"
  and param.getValue().getAstNode() instanceof AstNode
  and param.getValue().getAstNode().hasAncestor(
    MethodInvokeExpr(
      Name("request"),
      Name("args")
    )
  )
select call, "Potential URL redirection using unvalidated user input."