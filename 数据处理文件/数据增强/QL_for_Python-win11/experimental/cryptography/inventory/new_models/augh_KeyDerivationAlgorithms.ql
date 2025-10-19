/**
 * @name Key Derivation Algorithms
 * @description Identifies all instances where key derivation algorithms are used within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic key derivation operations
from KeyDerivationOperation keyDerivationOp
// Extract algorithm details from the operation
where exists(KeyDerivationAlgorithm algo | 
       algo = keyDerivationOp.getAlgorithm() and 
       algo.getKDFName() = algo.getKDFName())
// Output operation with algorithm identification
select keyDerivationOp,
  "Key derivation algorithm usage detected: " + 
  keyDerivationOp.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()