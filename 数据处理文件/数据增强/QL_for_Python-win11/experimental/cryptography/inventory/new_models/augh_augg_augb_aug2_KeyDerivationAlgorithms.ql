/**
 * @name Key Derivation Algorithms Detection
 * @description Identifies cryptographic key derivation functions in supported libraries.
 *              This detection is critical for quantum readiness assessment, as certain
 *              key derivation techniques may be vulnerable to quantum computing threats.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic key derivation operations
// These operations require security evaluation in the quantum computing context
from KeyDerivationOperation kdfOperation, KeyDerivationAlgorithm kdfAlgorithm
where kdfOperation.getAlgorithm() = kdfAlgorithm
select kdfOperation,
  "Detected key derivation function: " + kdfAlgorithm.getKDFName()