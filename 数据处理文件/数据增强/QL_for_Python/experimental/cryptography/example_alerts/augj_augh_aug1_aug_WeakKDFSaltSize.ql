/**
 * @name Insufficient KDF Salt Size
 * @description Detects Key Derivation Function (KDF) implementations with salt sizes below the security threshold of 128 bits (16 bytes).
 *
 * This rule identifies KDF operations where salt sizes are either:
 * - Explicitly configured below 16 bytes
 * - Cannot be statically determined during analysis
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeParam, API::CallNode urandomInvocation, string warningText
where
  // Verify KDF operation requires salt parameter
  kdfOperation.requiresSalt() and
  
  // Trace salt configuration to os.urandom source
  urandomInvocation = kdfOperation.getSaltConfigSrc() and
  urandomInvocation = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Identify ultimate salt size parameter source
  saltSizeParam = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Evaluate salt size security conditions
  (
    // Case 1: Non-static salt size configuration
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    warningText = "Salt size cannot be statically verified. "
    or
    // Case 2: Insufficient salt size
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    warningText = "Salt size is below minimum requirement. "
  )
select kdfOperation,
  warningText + "Minimum 16 bytes required for salt. os.urandom Config: $@, Size Config: $@", urandomInvocation,
  urandomInvocation.toString(), saltSizeParam, saltSizeParam.toString()