/**
 * @name Weak symmetric encryption algorithm
 * @description Identifies symmetric encryption algorithms that are considered weak, deprecated, or non-compliant with security standards.
 * 
 *              Acceptable key lengths are 128, 192, and 256 bits, which correspond to AES implementations.
 *              Any AES usage is deemed acceptable as these represent industry-standard encryption strengths.
 * @id py/weak-symmetric-encryption
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm cryptoOperation, string algorithmName, string alertMessage
where
  // Extract the encryption algorithm name from the cryptographic operation
  algorithmName = cryptoOperation.getEncryptionName() and
  // Exclude AES and its variants (AES128, AES192, AES256) from the detection
  algorithmName != ["AES", "AES128", "AES192", "AES256"] and
  // Generate appropriate alert message based on algorithm recognition status
  (
    algorithmName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized symmetric encryption algorithm."
    or
    algorithmName != unknownAlgorithm() and
    alertMessage = "Use of unapproved symmetric encryption algorithm or API " + algorithmName + "."
  )
select cryptoOperation, alertMessage