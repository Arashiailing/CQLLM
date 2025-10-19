import python

from Call c
where c.getTarget() = sqlite3::execute
and c.getArguments().size() > 1
and c.getArguments()[1].getExpression() is StringLiteral
select c, "Potential CWE-287: Password stored in clear text"