/**
 * @name Block cipher mode of operation detection
 * @description This query identifies cryptographic operations that utilize block cipher modes
 *              in various supported cryptographic libraries. It helps in analyzing the 
 *              encryption methods used in the codebase for security assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and determine their block cipher mode
from Cryptography::CryptographicOperation cryptoOperation, string blockCipherMode
where 
  // Extract the block cipher mode information from each cryptographic operation
  blockCipherMode = cryptoOperation.getBlockMode()
select 
  cryptoOperation, 
  "Cryptographic operation uses block cipher mode: " + blockCipherMode