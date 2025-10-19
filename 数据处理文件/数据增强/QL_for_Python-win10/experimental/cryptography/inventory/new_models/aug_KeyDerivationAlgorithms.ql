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
from KeyDerivationOperation kdfOperation

// Extract the algorithm name for reporting
// TODO: Consider extracting all configuration details from the operation?
select kdfOperation,
  "Key derivation algorithm detected: " + kdfOperation.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()