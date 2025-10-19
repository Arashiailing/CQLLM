/**
 * @name Insufficient KDF Salt Length
 * @description Key derivation function salts must be at least 128 bits (16 bytes) in length.
 * 
 * Detects two scenarios:
 * 1. Salt length is configured with a constant value smaller than 16 bytes
 * 2. Salt length cannot be statically verified (dynamic configuration)
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation kdfOp, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string alertMessage
where
  kdfOp.requiresSalt() and
  API::moduleImport("os").getMember("urandom").getACall() = urandomCall and
  urandomCall = kdfOp.getSaltConfigSrc() and
  saltSizeSource = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  (
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration uses non-static size. "
    or
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt size is below minimum requirement. "
  )
select kdfOp,
  alertMessage + "Minimum salt size is 16 bytes. os.urandom Config: $@, Size Config: $@", urandomCall,
  urandomCall.toString(), saltSizeSource, saltSizeSource.toString()