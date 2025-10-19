import python

from CallExpr c1, CallExpr c2
where (c1.getCallee().getName() = "request.args.get" or c1.getCallee().getName() = "request.form.get" or c1.getCallee().getName() = "request.cookies.get")
  and c2.getArg(0).getType() = c1.getArg(0).getType()
  and c2.getCallee().getName() = "os.path.join"
select c2, "Uncontrolled data used in path expression"