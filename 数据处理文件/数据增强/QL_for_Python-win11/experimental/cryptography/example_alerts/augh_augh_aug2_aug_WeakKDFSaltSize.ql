/**
 * @name Insufficient KDF Salt Size
 * @description Detects Key Derivation Function (KDF) salts that are below the minimum 128 bits (16 bytes) requirement.
 *
 * This rule identifies two types of security issues:
 * 1. Salt size configuration explicitly set to less than 128 bits
 * 2. Salt size that cannot be statically determined during code analysis
 * 
 * The analysis focuses on salt configurations utilizing os.urandom() function calls.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify KDF operations with problematic salt configurations
from KeyDerivationOperation keyDerivationFunc, DataFlow::Node saltSizeParam, API::CallNode urandomInvocation, string issueDescription
where
  // Ensure the KDF operation requires salt configuration
  keyDerivationFunc.requiresSalt() and
  
  // Validate that salt source originates from os.urandom() call
  urandomInvocation = keyDerivationFunc.getSaltConfigSrc() and
  urandomInvocation = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Track the salt size parameter to its origin
  saltSizeParam = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Check for two distinct salt configuration vulnerabilities
  (
    // Case 1: Salt size cannot be statically determined
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    issueDescription = "Salt configuration size is not statically verifiable. "
    or
    // Case 2: Salt size is below minimum security requirement
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    issueDescription = "Salt configuration size is below minimum requirement. "
  )

// Generate findings with detailed contextual information
select keyDerivationFunc,
  issueDescription + "Salt size must be at least 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomInvocation,
  urandomInvocation.toString(), 
  saltSizeParam, 
  saltSizeParam.toString()