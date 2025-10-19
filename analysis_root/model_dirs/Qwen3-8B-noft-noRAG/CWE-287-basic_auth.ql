import python

/**
 * @name CWE-287: Improper Authentication
 */
from StringLiteral s
where s.getValue().matches(".*(?:password|secret|token|key)(?:[:=][^\s\\"]+)?.*")
  and not s.getEnclosingFunction().getName().matches("^(test|mock|sample).*")
  and not s.getSourceLocation().getFilePath().matches("^(tests?|examples?|docs).*")
select s, "Potential sensitive credential stored in clear text"