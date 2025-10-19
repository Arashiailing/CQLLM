/**
 * @name Key Derivation Algorithms Detection
 * @description Identifies and reports usage of cryptographic key derivation functions 
 *              across supported cryptographic libraries. This query helps in tracking 
 *              key derivation mechanisms for cryptographic bill of materials (CBOM) generation.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// This query identifies cryptographic operations that derive keys
// from initial values, which is critical for security analysis
from KeyDerivationOperation kdfOperation

// Generate alert with the specific key derivation algorithm name
select kdfOperation,
  "Cryptographic key derivation function detected: " + 
  kdfOperation.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()