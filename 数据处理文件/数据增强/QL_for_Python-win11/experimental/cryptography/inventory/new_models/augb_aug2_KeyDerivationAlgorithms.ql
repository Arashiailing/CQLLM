/**
 * @name Key Derivation Algorithms
 * @description Identifies usage of cryptographic key derivation functions in supported libraries.
 *              This detection is crucial for assessing the quantum readiness of cryptographic
 *              implementations, as certain key derivation methods may be vulnerable to
 *              quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Query to detect cryptographic key derivation operations
// These operations are important for security assessment in quantum computing context
from KeyDerivationOperation kdfOp
// Generate alert with specific algorithm information
select kdfOp,
  "Key derivation function detected: " + 
  kdfOp.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()