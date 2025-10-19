/**
 * @name Weak KDF Mode
 * @description Detects when a key derivation function (KDF) uses a mode other than CounterMode
 * @kind problem
 * @id py/kdf-weak-mode
 * @problem.severity error
 * @precision high
 */

// Import standard Python library
import python
// Import experimental cryptography concepts
import experimental.cryptography.Concepts
// Private import of experimental cryptography utilities, aliased as Utils
private import experimental.cryptography.utils.Utils as Utils

// Identify KDF operations with non-CounterMode configurations
from KeyDerivationOperation kdfOperation, DataFlow::Node modeConfigurationSource
where
  // Verify that the KDF operation requires a mode specification
  kdfOperation.requiresMode() and
  // Extract the mode configuration source from the operation
  modeConfigurationSource = kdfOperation.getModeSrc() and
  // Ensure the mode is not CounterMode (which is the secure option)
  not modeConfigurationSource =
    // Reference to the secure CounterMode
    API::moduleImport("cryptography")
        .getMember("hazmat")
        .getMember("primitives")
        .getMember("kdf")
        .getMember("kbkdf")
        .getMember("Mode")
        .getMember("CounterMode")
        .asSource()
// Report the insecure KDF operation with details about the mode configuration
select kdfOperation, "Key derivation mode is not set to CounterMode. Mode Config: $@", modeConfigurationSource,
  modeConfigurationSource.toString()