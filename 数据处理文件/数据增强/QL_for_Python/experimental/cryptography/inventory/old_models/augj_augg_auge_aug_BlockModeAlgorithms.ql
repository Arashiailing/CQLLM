/**
 * @name Block cipher mode detection
 * @description Identifies cryptographic operations that utilize block cipher modes
 *              within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and their corresponding block cipher modes
from Cryptography::CryptographicOperation cryptoOperation, string cipherMode
where 
  // Retrieve the block cipher mode from the cryptographic operation
  cipherMode = cryptoOperation.getBlockMode()
select 
  cryptoOperation, 
  "Cryptographic operation uses block cipher mode: " + cipherMode