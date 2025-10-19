import python

/**
 * CWE-522: Insufficiently Protected Credentials
 * This query detects instances where credentials are stored in cleartext.
 */

from Variable credVar, StringLiteral credValue
where credVar.getAnAssignment() = credValue and
      credValue.getValue().matches(".*password.*|.*secret.*|.*key.*|.*token.*")
select credVar, "Credentials are stored in cleartext: " + credValue.getValue()