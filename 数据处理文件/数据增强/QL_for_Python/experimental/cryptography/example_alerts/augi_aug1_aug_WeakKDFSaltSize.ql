/**
 * @name Insufficient KDF Salt Size
 * @description Identifies Key Derivation Function (KDF) operations utilizing salt sizes below the recommended 128 bits (16 bytes).
 *
 * This security rule detects KDF implementations where the salt size is either statically determined to be
 * less than the minimum required 128 bits, or cannot be statically determined during code analysis.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Query to detect KDF operations with inadequate salt size
from KeyDerivationOperation kdfOp, DataFlow::Node saltSizeArg, API::CallNode urandomCall, string alertMessage
where
  // Ensure we're only examining KDF operations that require a salt parameter
  kdfOp.requiresSalt() and
  
  // Confirm that the salt configuration is sourced from os.urandom
  urandomCall = kdfOp.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace back to the ultimate source of the salt size parameter
  saltSizeArg = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Evaluate two distinct security concern scenarios
  (
    // Security concern 1: Salt size cannot be statically verified
    not exists(saltSizeArg.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration uses a non-statically verifiable size. "
    or
    // Security concern 2: Salt size is cryptographically insufficient
    saltSizeArg.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt configuration is cryptographically insufficient. "
  )
select kdfOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", urandomCall,
  urandomCall.toString(), saltSizeArg, saltSizeArg.toString()