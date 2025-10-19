import python

/**
 * This query detects instances of CWE-522: Insufficiently Protected Credentials.
 * It looks for cases where credentials are stored in a way that is not sufficiently protected.
 */

from StringLiteral credential, Variable var, AssignmentStmt assignment
where credential.getValue().matches(".*password.*|.*secret.*|.*key.*")
  and assignment.getLHS() = var
  and assignment.getRHS() = credential
select assignment, "Credentials are stored in a variable without proper protection."