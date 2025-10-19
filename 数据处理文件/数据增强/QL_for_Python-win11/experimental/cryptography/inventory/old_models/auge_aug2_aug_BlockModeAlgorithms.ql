/**
 * @name Identification of Block Cipher Modes
 * @description Discovers encryption/decryption operations employing block cipher modes
 *              in supported cryptographic frameworks.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and retrieve their block cipher mode information
from Cryptography::CryptographicOperation cryptoOp, string cipherMode
where 
  // Retrieve the block cipher mode identifier from the cryptographic operation
  cipherMode = cryptoOp.getBlockMode()
select 
  cryptoOp, 
  "Cryptographic operation uses block cipher mode: " + cipherMode