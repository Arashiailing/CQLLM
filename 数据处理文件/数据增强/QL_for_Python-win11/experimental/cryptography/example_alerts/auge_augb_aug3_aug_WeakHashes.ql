/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash functions that are either
 *              not approved or considered weak for security-critical applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python modules and cryptography-related concepts
import python
import experimental.cryptography.Concepts

// Find hash operations using weak or unapproved cryptographic algorithms
from HashAlgorithm hashFunc, string hashAlgorithm, string warningMsg
where
  // Extract the algorithm name from the hash operation
  hashAlgorithm = hashFunc.getHashName() and
  // Exclude strong, approved hash algorithms from detection
  not hashAlgorithm = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate warning based on algorithm recognition status
  (
    // Case: Algorithm is recognized but not approved
    hashAlgorithm != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + hashAlgorithm + "."
    or
    // Case: Algorithm is not recognized
    hashAlgorithm = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashFunc, warningMsg