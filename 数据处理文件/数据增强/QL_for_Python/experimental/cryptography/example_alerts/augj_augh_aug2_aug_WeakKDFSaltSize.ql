/**
 * @name Insufficient KDF Salt Size
 * @description Detects Key Derivation Function (KDF) implementations with inadequate salt length.
 * 
 * A secure KDF requires salt values of at least 128 bits (16 bytes) to prevent
 * brute-force and rainbow table attacks. This rule identifies:
 * 1. Salt size configurations that are explicitly below the 16-byte minimum
 * 2. Salt size configurations that cannot be statically verified at analysis time
 * 
 * The analysis focuses on salt generation through os.urandom() function calls.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify problematic KDF salt configurations
from KeyDerivationOperation keyDerivationOp, DataFlow::Node saltSizeParam, 
     API::CallNode urandomInvocation, string warningMsg
where
  // Validate KDF operation requires salt configuration
  keyDerivationOp.requiresSalt() and
  
  // Verify salt source originates from os.urandom() function
  urandomInvocation = keyDerivationOp.getSaltConfigSrc() and
  urandomInvocation = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace salt size parameter to its origin
  saltSizeParam = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Detect salt configuration vulnerabilities
  (
    // Case 1: Salt size cannot be statically determined
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt configuration uses non-static size. "
    or
    // Case 2: Salt size is below security threshold
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt configuration violates minimum size requirement. "
  )

// Generate security alert with contextual details
select keyDerivationOp,
  warningMsg + "Minimum required salt size is 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  urandomInvocation,
  urandomInvocation.toString(), 
  saltSizeParam, 
  saltSizeParam.toString()