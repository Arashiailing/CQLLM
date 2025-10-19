/**
 * @name Weak KDF Mode Detection
 * @description Detects key derivation functions that don't utilize CounterMode,
 *              which is the strongly recommended secure mode for cryptographic key derivation
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
  KeyDerivationOperation keyDerivFunc, 
  DataFlow::Node actualModeSetting,
  DataFlow::Node recommendedCounterMode
where
  // Define the secure CounterMode reference from cryptography API hierarchy
  recommendedCounterMode = API::moduleImport("cryptography")
                      .getMember("hazmat")
                      .getMember("primitives")
                      .getMember("kdf")
                      .getMember("kbkdf")
                      .getMember("Mode")
                      .getMember("CounterMode")
                      .asSource() and
  // Verify that the KDF operation requires mode configuration
  keyDerivFunc.requiresMode() and
  // Extract the actual mode configuration from the KDF operation
  actualModeSetting = keyDerivFunc.getModeSrc() and
  // Check if the configured mode differs from the secure CounterMode
  actualModeSetting != recommendedCounterMode
select 
  keyDerivFunc, 
  "Key derivation mode is not set to CounterMode. Mode Config: $@", 
  actualModeSetting,
  actualModeSetting.toString()