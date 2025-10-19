/**
 * @name Key Derivation Algorithms Detection
 * @description Identifies cryptographic key derivation functions in supported libraries.
 *              This detection is crucial for assessing quantum readiness of cryptographic systems,
 *              as certain key derivation techniques may be vulnerable to quantum computing threats.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic key derivation operations
// These operations are essential for security evaluation in the context of quantum computing
from KeyDerivationOperation kdfOperation
where kdfOperation.getAlgorithm() instanceof KeyDerivationAlgorithm
select kdfOperation,
  "Detected key derivation function: " + 
  kdfOperation.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()