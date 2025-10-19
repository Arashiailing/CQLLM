/**
 * @name Weak KDF salt generation
 * @description Detects weak salt generation in Key Derivation Functions (KDFs). 
 *              Salts should be generated using os.urandom for cryptographic security.
 * @kind problem
 * @id py/kdf-weak-salt-gen
 * @problem.severity error
 * @precision high
 */

// Import standard Python language library
import python
// Import experimental cryptography concepts for KDF analysis
import experimental.cryptography.Concepts
// Private import of cryptographic utilities aliased as Utils
private import experimental.cryptography.utils.Utils as Utils

// Identify Key Derivation Functions and their salt origins
from KeyDerivationOperation keyDerivationFunc, DataFlow::Node saltOrigin
where 
  // Condition 1: The KDF requires a salt parameter
  keyDerivationFunc.requiresSalt() and
  // Condition 2: The salt origin is from the KDF's salt configuration
  saltOrigin = keyDerivationFunc.getSaltConfigSrc() and
  // Condition 3: The salt origin is not from os.urandom
  not API::moduleImport("os").getMember("urandom").getACall() = saltOrigin
// Report KDF operations with weak salt generation
select keyDerivationFunc, "Salt configuration is not from an accepted random source: $@. Must be os.urandom",
  saltOrigin, saltOrigin.toString()