/**
 * @name Weak KDF Mode
 * @description Identifies key derivation functions that fail to use CounterMode,
 *              which is the recommended secure mode for cryptographic key derivation
 * @kind problem
 * @id py/kdf-weak-mode
 * @problem.severity error
 * @precision high
 */

// Import Python language module for code analysis
import python
// Import experimental cryptography concepts for KDF detection
import experimental.cryptography.Concepts
// Import cryptography utilities with shortened alias for convenience
private import experimental.cryptography.utils.Utils as CryptoUtils

from 
  KeyDerivationOperation kdfOperation, 
  DataFlow::Node configuredModeNode,
  DataFlow::Node secureCounterModeRef
where
  // Define the secure CounterMode reference from cryptography API
  secureCounterModeRef = API::moduleImport("cryptography")
                      .getMember("hazmat")
                      .getMember("primitives")
                      .getMember("kdf")
                      .getMember("kbkdf")
                      .getMember("Mode")
                      .getMember("CounterMode")
                      .asSource() and
  // Verify that the KDF operation requires mode configuration
  kdfOperation.requiresMode() and
  // Extract the actual mode configuration from the KDF operation
  configuredModeNode = kdfOperation.getModeSrc() and
  // Ensure the configured mode is not the secure CounterMode
  not configuredModeNode = secureCounterModeRef
select 
  kdfOperation, 
  "Key derivation mode is not set to CounterMode. Mode Config: $@", 
  configuredModeNode,
  configuredModeNode.toString()