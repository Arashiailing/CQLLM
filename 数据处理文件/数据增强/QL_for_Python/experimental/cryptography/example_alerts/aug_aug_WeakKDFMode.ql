/**
 * @name Weak KDF Mode
 * @description Detects when key derivation functions are not using CounterMode,
 *              which is the recommended secure mode for KDF operations
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
  KeyDerivationOperation keyDerivationFunc, 
  DataFlow::Node modeConfigNode,
  DataFlow::Node counterModeReference
where
  // Define the secure CounterMode reference from cryptography API
  counterModeReference = API::moduleImport("cryptography")
                      .getMember("hazmat")
                      .getMember("primitives")
                      .getMember("kdf")
                      .getMember("kbkdf")
                      .getMember("Mode")
                      .getMember("CounterMode")
                      .asSource() and
  // Check if the KDF operation requires mode configuration
  keyDerivationFunc.requiresMode() and
  // Extract the actual mode configuration from the KDF operation
  modeConfigNode = keyDerivationFunc.getModeSrc() and
  // Verify that the configured mode is not the secure CounterMode
  not modeConfigNode = counterModeReference
select 
  keyDerivationFunc, 
  "Key derivation mode is not set to CounterMode. Mode Config: $@", 
  modeConfigNode,
  modeConfigNode.toString()