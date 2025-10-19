/**
 * @name Weak KDF Mode
 * @description Detects when a Key Derivation Function (KDF) is configured with a mode other than CounterMode,
 *              which is considered insecure. KDF operations should always use CounterMode for proper security.
 * @kind problem
 * @id py/kdf-weak-mode
 * @problem.severity error
 * @precision high
 */

// Import Python language library
import python
// Import experimental cryptography concepts for security analysis
import experimental.cryptography.Concepts
// Import experimental cryptography utilities with alias for helper functions
private import experimental.cryptography.utils.Utils as Utils

// Select KDF operations that are using insecure modes
from KeyDerivationOperation kdfOperation, DataFlow::Node modeConfigurationSource
where
  // Check if the KDF operation requires a mode configuration
  kdfOperation.requiresMode() and
  // Get the source of the mode configuration for this operation
  modeConfigurationSource = kdfOperation.getModeSrc() and
  // Verify that the mode is not the secure CounterMode
  not modeConfigurationSource =
    API::moduleImport("cryptography")
        .getMember("hazmat")
        .getMember("primitives")
        .getMember("kdf")
        .getMember("kbkdf")
        .getMember("Mode")
        .getMember("CounterMode")
        .asSource()
// Report the insecure KDF operation with details about the problematic mode configuration
select kdfOperation, "Key derivation mode is not set to CounterMode. Mode Config: $@", modeConfigurationSource,
  modeConfigurationSource.toString()