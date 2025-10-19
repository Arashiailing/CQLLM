/**
 * @name Key Derivation Algorithms
 * @description Detects all occurrences of key derivation function (KDF) usage in supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Define a variable to hold the key derivation operation
from KeyDerivationOperation kdfOperation
// Check if the operation has an associated key derivation algorithm
where exists(KeyDerivationAlgorithm kdfAlgorithm | 
       kdfAlgorithm = kdfOperation.getAlgorithm())
// Display the operation along with its algorithm name
select kdfOperation,
  "Key derivation algorithm usage detected: " + 
  kdfOperation.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()