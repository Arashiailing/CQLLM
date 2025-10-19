import python

/**
 * Detects potential cleartext storage of sensitive information like passwords.
 * This query looks for direct assignments or literals containing 'password'
 * in contexts that might indicate insecure storage.
 */
from AssignmentExpr assign
where assign.getLeftHandSide().isIdentifier() 
  and (assign.getRightHandSide().isStringLiteral() 
       or assign.getRightHandSide().isDictLiteral())
  and assign.getRightHandSide().toString().contains("password")
select assign.getLocation(), "Potential cleartext storage of sensitive information detected."