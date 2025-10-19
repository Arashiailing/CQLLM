/**
 * @name Insufficient KDF Salt Length Detection
 * @description Detects cryptographic key derivation functions (KDFs) 
 * using salt values with inadequate length. Flags cases where salt size 
 * is either below 128 bits (16 bytes) or cannot be statically determined.
 * 
 * The query identifies KDF operations requiring salt, traces salt configuration 
 * through os.urandom calls, and validates salt size parameters against 
 * cryptographic best practices.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOp, 
     DataFlow::Node saltSizeSrc, 
     API::CallNode urandomNode, 
     string warningMsg
where
  // Ensure KDF operation requires salt configuration
  kdfOp.requiresSalt() and
  
  // Identify salt configuration source and trace size parameter
  exists(API::CallNode saltConfigCall |
    // Salt must be configured via os.urandom
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigCall and
    saltConfigCall = kdfOp.getSaltConfigSrc() and
    urandomNode = saltConfigCall and
    saltSizeSrc = Utils::getUltimateSrcFromApiNode(urandomNode.getParameter(0, "size"))
  ) and
  
  // Validate salt size and generate appropriate warning
  (
    // Case 1: Salt size cannot be statically verified
    not exists(saltSizeSrc.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt configuration does not use a statically verifiable size. "
    or
    // Case 2: Salt size is below minimum requirement
    saltSizeSrc.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt configuration uses an insufficiently large size. "
  )
select kdfOp,
  warningMsg + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomNode, urandomNode.toString(), 
  saltSizeSrc, saltSizeSrc.toString()