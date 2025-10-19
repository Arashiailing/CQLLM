import python

from Call c, Argument a
where c.getCallee().getName() = "print" and a.getArgument().hasUserInput()
select c, "Potential Reflected XSS: User input is directly output without escaping."