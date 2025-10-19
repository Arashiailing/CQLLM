/**
 * @name Weak KDF Mode
 * @description Identifies key derivation functions that fail to utilize CounterMode,
 *              which is the recommended secure configuration for KDF implementations
 * @kind problem
 * @id py/kdf-weak-mode
 * @problem.severity error
 * @precision high
 */

// Import Python language module for security analysis
import python
// Import experimental cryptography concepts for KDF identification
import experimental.cryptography.Concepts
// Import cryptography utilities with abbreviated alias for enhanced readability
private import experimental.cryptography.utils.Utils as CryptoUtils

from 
  KeyDerivationOperation kdfOperation, 
  DataFlow::Node configuredMode,
  DataFlow::Node secureCounterMode
where
  // Establish reference to the secure CounterMode from cryptography API
  secureCounterMode = API::moduleImport("cryptography")
                      .getMember("hazmat")
                      .getMember("primitives")
                      .getMember("kdf")
                      .getMember("kbkdf")
                      .getMember("Mode")
                      .getMember("CounterMode")
                      .asSource() and
  // Determine if the KDF operation necessitates mode configuration
  kdfOperation.requiresMode() and
  // Retrieve the actual mode configuration from the KDF operation
  configuredMode = kdfOperation.getModeSrc() and
  // Confirm that the configured mode differs from the secure CounterMode
  not configuredMode = secureCounterMode
select 
  kdfOperation, 
  "Key derivation function is not configured with CounterMode. Current Mode Setting: $@", 
  configuredMode,
  configuredMode.toString()