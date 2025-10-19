/**
 * @name Key Derivation Algorithms
 * @description Identifies usage of cryptographic key derivation functions in supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Query logic to identify key derivation operations
from KeyDerivationOperation keyDerivationOp
// Construct alert message with algorithm details
select keyDerivationOp,
  "Key derivation function detected: " + 
  keyDerivationOp.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()