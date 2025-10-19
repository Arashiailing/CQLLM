import python

from Call site callSite, StringLiteral stringLiteral, Variable var
where callSite.getExpression() = stringLiteral + var
select callSite, "Potential reflected XSS due to direct user input in HTML."