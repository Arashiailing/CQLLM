import python

from Call c
where c.getCallee() = "open" and c.getArgument(0) is userInput
select c, "Uncontrolled data used in path expression, potential CWE-22 (Path Injection)"