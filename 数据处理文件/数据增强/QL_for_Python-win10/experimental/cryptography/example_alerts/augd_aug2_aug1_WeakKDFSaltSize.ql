/**
 * @name Small KDF salt length.
 * @description Detects KDF operations with insufficient salt size.
 * 
 * This query identifies cryptographic key derivation functions (KDFs) that use
 * salt values with insufficient length. It flags cases where the salt size is
 * either less than 128 bits (16 bytes) or cannot be statically verified.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOperation, 
     DataFlow::Node saltSizeSource, 
     API::CallNode urandomCall, 
     string alertMessage
where
  // Identify KDF operations requiring salt configuration
  kdfOperation.requiresSalt() and
  
  // Trace salt configuration to os.urandom calls and extract size parameter source
  exists(API::CallNode saltConfigCall |
    saltConfigCall = kdfOperation.getSaltConfigSrc() and
    saltConfigCall = API::moduleImport("os").getMember("urandom").getACall() and
    urandomCall = saltConfigCall and
    saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Validate salt size requirements
  (
    // Case 1: Non-static salt size (cannot be verified at analysis time)
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Static salt size below minimum threshold (16 bytes)
    exists(int size |
      size = saltSizeSource.asExpr().(IntegerLiteral).getValue() and
      size < 16
    ) and
    alertMessage = "Salt config is insufficiently large. "
  )
select kdfOperation,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()