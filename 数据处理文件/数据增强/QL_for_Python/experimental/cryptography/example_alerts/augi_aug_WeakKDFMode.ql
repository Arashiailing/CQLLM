/**
 * @name Insecure KDF Configuration
 * @description Identifies Key Derivation Function (KDF) implementations that use modes other than CounterMode,
 *              which are considered vulnerable to attacks. Proper KDF security requires CounterMode usage.
 * @kind problem
 * @id py/kdf-weak-mode
 * @problem.severity error
 * @precision high
 */

// Import Python language support
import python
// Import experimental cryptography security analysis concepts
import experimental.cryptography.Concepts
// Import experimental cryptography utilities with alias for helper functions
private import experimental.cryptography.utils.Utils as Utils

// Find KDF operations with insecure mode configurations
from KeyDerivationOperation keyDerivationOp, DataFlow::Node modeSource
where
  // Ensure the KDF operation requires mode configuration
  keyDerivationOp.requiresMode() and
  // Identify the source of the mode configuration
  modeSource = keyDerivationOp.getModeSrc() and
  // Check that the mode is not the secure CounterMode
  not modeSource =
    API::moduleImport("cryptography")
        .getMember("hazmat")
        .getMember("primitives")
        .getMember("kdf")
        .getMember("kbkdf")
        .getMember("Mode")
        .getMember("CounterMode")
        .asSource()
// Report the insecure KDF operation with details about the problematic mode configuration
select keyDerivationOp, "Key derivation mode is not set to CounterMode. Mode Config: $@", modeSource,
  modeSource.toString()