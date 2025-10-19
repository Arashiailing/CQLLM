import python

from Call c1, Call c2
where c1.getSelector() = "request.args.get"
  and c2.getSelector() = "return"
  and c2.getArg(0) = c1.getArg(0)
select c1, c2, "Potential reflected XSS due to direct user input in response."