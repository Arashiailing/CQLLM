import python

from Call c, StringConcatenation sc, Argument arg
where c.getTarget().getSignature() = "subprocess.run" and
      sc.getExpression() = c.getArgument(0) and
      arg.getLocation() = sc.getLocation()
select c.getLocation(), "Potential command injection vulnerability via unsafe shell command construction"