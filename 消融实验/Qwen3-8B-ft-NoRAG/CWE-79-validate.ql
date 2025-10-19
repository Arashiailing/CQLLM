import py

from CallExpr c, Variable v
where c.getFunction().getName() = "print" and
      v.isAssignedTo(request.args.get()) and
      c.getArgument(0).getName() = v.getName()
select c, "Potential Reflected XSS via direct output of user input"