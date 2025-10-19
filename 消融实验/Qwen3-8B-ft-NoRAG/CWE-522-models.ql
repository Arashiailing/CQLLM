import python

from StringLiteral s
where s.getValue().matches(".*password.*|.*secret.*|.*key.*|.*token.*|.*cred.*")
select s, "Potential CWE-522: Sensitive information stored in plain text."