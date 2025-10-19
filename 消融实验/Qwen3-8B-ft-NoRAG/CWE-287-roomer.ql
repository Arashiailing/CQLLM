import python

from Call c, Argument a
where c.getQualifiedName() = "subprocess.check_output" or
      c.getQualifiedName() = "subprocess.run" or
      c.getQualifiedName() = "subprocess.call" or
      c.getQualifiedName() = "subprocess.Popen" or
      c.getQualifiedName() = "os.system" or
      c.getQualifiedName() = "os.popen"
  and a.isString() and a.getExpression().hasUserInput()
select c, "Potential command injection vulnerability via unfiltered argument."