/**
 * @name Weak hashes
 * @description Detects usage of cryptographic hash algorithms that are either unapproved or considered weak for security purposes.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic concepts
import python
import experimental.cryptography.Concepts

// Identify cryptographic hash operations, their algorithm names, and corresponding alert messages
from HashAlgorithm cryptoHashOp, string algorithmName, string alertMessage
where
  // Extract the algorithm name from the hash operation
  algorithmName = cryptoHashOp.getHashName() and
  // Define secure hash algorithms that are approved for use
  exists(string approvedAlgorithm | approvedAlgorithm = ["SHA256", "SHA384", "SHA512"] |
    // Filter out operations using approved algorithms
    not algorithmName = approvedAlgorithm
  ) and
  // Generate appropriate alert message based on algorithm recognition status
  (if algorithmName = unknownAlgorithm()
   then alertMessage = "Use of unrecognized hash algorithm."
   else alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + ".")
select cryptoHashOp, alertMessage