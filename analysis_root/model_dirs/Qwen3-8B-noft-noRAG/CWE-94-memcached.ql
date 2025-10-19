import python

from Call c, Argument arg
where c.getTarget().getName() = "loads" and c.getModule().getName() = "pickle"
  and arg.getValue().isUserInput()
select c, "Unsafe deserialization using pickle.loads with untrusted user input."