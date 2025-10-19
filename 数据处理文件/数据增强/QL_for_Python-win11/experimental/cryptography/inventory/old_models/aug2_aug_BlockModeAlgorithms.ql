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

// Detect cryptographic operations and extract their block cipher mode configuration
from Cryptography::CryptographicOperation cryptoOperation, string blockCipherMode
where 
  // Extract the block cipher mode name from the cryptographic operation
  blockCipherMode = cryptoOperation.getBlockMode()
select 
  cryptoOperation, 
  "Cryptographic operation uses block cipher mode: " + blockCipherMode