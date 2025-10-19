import python

from Call call, StringLiteral literal
where call.getTarget() = "db.execute" and call.getArgument(0).getValue() = literal and literal.getValue().contains("password")
select call, "Potential CWE-287: Password stored in clear text"