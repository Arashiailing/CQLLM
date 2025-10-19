import python

/**
 * CWE-287: Improper Authentication
 * Detects instances where credentials are stored in cleartext.
 */
from StringLiteral credential, Variable var, AssignmentStmt assignment
where assignment.getLhs() = var and
      assignment.getRhs() = credential and
      credential.getValue().matches(".*password.*|.*secret.*|.*key.*|.*token.*")
select credential, "Credentials are stored in cleartext."