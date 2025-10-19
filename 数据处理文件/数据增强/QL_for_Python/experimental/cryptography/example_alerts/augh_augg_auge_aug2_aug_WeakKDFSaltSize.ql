/**
 * @name Insufficient KDF Salt Size
 * @description Detects insecure Key Derivation Function (KDF) salt configurations.
 *
 * This security analysis identifies two critical vulnerabilities in KDF implementations:
 * 1. Salt size configured below the 128-bit (16-byte) minimum security threshold
 * 2. Salt size that cannot be statically determined at analysis time
 * 
 * The query focuses on salt configurations using os.urandom() calls, which are
 * commonly employed for generating cryptographically secure random salts.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

// Define the main security analysis to detect vulnerable KDF salt configurations
from KeyDerivationOperation keyDerivationFunc, 
     DataFlow::Node saltSizeParamSource, 
     API::CallNode osUrandomCall, 
     string vulnerabilityDescription
where
  // Verify that the KDF operation requires a salt parameter
  keyDerivationFunc.requiresSalt() and
  
  // Confirm the salt configuration is derived from os.urandom function
  osUrandomCall = keyDerivationFunc.getSaltConfigSrc() and
  osUrandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace the salt size parameter to its origin for security evaluation
  saltSizeParamSource = CryptoUtils::getUltimateSrcFromApiNode(osUrandomCall.getParameter(0, "size")) and
  
  // Detect two distinct security vulnerability patterns in salt configuration
  (
    // Security Issue 1: Non-static salt size (determined at runtime)
    not exists(saltSizeParamSource.asExpr().(IntegerLiteral).getValue()) and
    vulnerabilityDescription = "Salt configuration uses non-static size. "
    or
    // Security Issue 2: Salt size below 16-byte minimum security requirement
    saltSizeParamSource.asExpr().(IntegerLiteral).getValue() < 16 and
    vulnerabilityDescription = "Salt configuration is too small. "
  )

// Generate security alerts with comprehensive contextual information
select keyDerivationFunc,
  vulnerabilityDescription + "Minimum required salt size is 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  osUrandomCall,
  osUrandomCall.toString(), 
  saltSizeParamSource, 
  saltSizeParamSource.toString()