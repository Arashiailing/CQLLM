/**
 * @name Key Derivation Algorithms
 * @description Identifies all instances of key derivation operations across supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify all key derivation operations in the codebase
// Each operation represents an invocation of a key derivation function
from KeyDerivationOperation keyDerivationOp

// Extract the algorithm name for reporting
// Note: Algorithm details are retrieved through the operation's associated algorithm object
// TODO: Consider extracting all configuration details from the operation?
select keyDerivationOp,
  "Key derivation algorithm detected: " + 
  keyDerivationOp.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()