import python

from Call c
where c.getCallee() = "pickle.loads"
select c, "Unsafe deserialization without input validation"