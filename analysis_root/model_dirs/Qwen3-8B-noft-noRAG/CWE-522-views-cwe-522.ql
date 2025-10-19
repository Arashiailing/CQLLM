import python

/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description Detects storage of credentials in cleartext.
 */
query CWE_522_CleartextStorage() {
  // Find calls to functions that store data (e.g., file writes, database inserts)
  // and check if the stored value is a credential (e.g., password, secret)
  
  // Identify potential credential values by their content
  var stringLiteral = StringLiteral
    | where stringWith("password") or stringWith("secret") or stringWith("token")
    
  // Check for direct storage operations without encryption/hashing
  select 
    (stringLiteral as s),
    "Potential CWE-522: Credential stored in cleartext" as message,
    "This string may contain a credential stored without protection." as explanation
    // Example: detect JSON dump with unencrypted credential
    from 
      Call c
      where c.getDecl().getName() = "json.dump"
        and c.getArg(0) = s
        and not exists(
          c.getCallee().getFunction()
           .getSymbolicExpressionTree()
           .getChildren()
           .filter(child -> child.isInstanceOf(HashFunction::class))
        )
}