/**
 * @name Key Derivation Algorithms
 * @description This query identifies all instances of key derivation operations across supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Extract algorithm name from key derivation operations
// TODO: Consider extracting all configuration details from the operation?
from KeyDerivationOperation keyDerivationOp, 
     KeyDerivationAlgorithm derivationAlgorithm, 
     string algorithmName
where 
  derivationAlgorithm = keyDerivationOp.getAlgorithm() and 
  algorithmName = derivationAlgorithm.getKDFName()
select keyDerivationOp, 
  "Key derivation algorithm detected: " + algorithmName