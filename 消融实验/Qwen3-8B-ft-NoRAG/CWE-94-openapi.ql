import python

from Call c, InputSource s
where c.getCallee() = "pickle.loads" and c.getArg(0) = s
select c, "Potential unsafe deserialization via pickle.loads with user input"