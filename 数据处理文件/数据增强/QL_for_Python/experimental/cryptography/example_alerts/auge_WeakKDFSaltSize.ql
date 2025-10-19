/**
 * @name Small KDF salt length.
 * @description Detects insufficient salt sizes in Key Derivation Functions (KDFs).
 * 
 * This query identifies KDF operations where:
 * 1. Salt size is configured via os.urandom with a static value < 16 bytes
 * 2. Salt size cannot be statically verified (non-constant value)
 * @id py/kdf-small-salt-size
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation kdfOp, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string alertMessage
where
  // Ensure operation requires salt configuration
  kdfOp.requiresSalt() and
  // Identify os.urandom calls used for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = urandomCall and
  // Verify this call configures salt for the KDF operation
  urandomCall = kdfOp.getSaltConfigSrc() and
  // Trace salt size parameter to its ultimate source
  saltSizeSource = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  // Evaluate salt size sufficiency
  (
    // Case 1: Non-static salt size configuration
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Static salt size < 16 bytes (128 bits)
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )
select kdfOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall, 
  urandomCall.toString(), 
  saltSizeSource, 
  saltSizeSource.toString()