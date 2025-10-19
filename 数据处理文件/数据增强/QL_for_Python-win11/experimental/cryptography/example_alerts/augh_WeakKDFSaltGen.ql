/**
 * @name Weak KDF salt generation.
 * @description Key derivation function (KDF) salts must be generated using an approved random number generator, specifically os.urandom
 * @kind problem
 * @id py/kdf-weak-salt-gen
 * @problem.severity error
 * @precision high
 */

// Import Python standard library
import python
// Import experimental cryptography concepts
import experimental.cryptography.Concepts
// Private import of experimental cryptography utilities aliased as Utils
private import experimental.cryptography.utils.Utils as Utils

// Select data flow nodes from key derivation operations and salt sources
from KeyDerivationOperation kdfOp, DataFlow::Node saltSource
// Conditions: operation requires salt, salt source is the operation's salt configuration source, and salt source is not from os.urandom call
where
  kdfOp.requiresSalt() and
  saltSource = kdfOp.getSaltConfigSrc() and
  not API::moduleImport("os").getMember("urandom").getACall() = saltSource
// Select operation and related information to report the issue
select kdfOp, "Salt configuration is not from an accepted random source: $@. Must be os.urandom",
  saltSource, saltSource.toString()