/**
 * @name Weak cryptographic hash algorithms
 * @description Detects the use of cryptographic hash algorithms that are either not approved
 *              for security applications or are considered cryptographically weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary modules for Python language support and cryptographic analysis
import python
import experimental.cryptography.Concepts

// Define the set of approved strong cryptographic hash algorithms
string approvedStrongHashAlgorithm() {
  result = ["SHA256", "SHA384", "SHA512"]
}

// Identify weak cryptographic hash operations and generate security alerts
from HashAlgorithm hashOperation, string hashAlgorithmName, string securityMessage
where
  // Extract the name of the cryptographic hash algorithm from the operation
  hashAlgorithmName = hashOperation.getHashName() and
  // Ensure the algorithm is not in the approved strong hash list
  not hashAlgorithmName = approvedStrongHashAlgorithm() and
  // Generate appropriate security message based on algorithm recognition
  (
    // Case for unrecognized algorithms
    hashAlgorithmName = unknownAlgorithm() and
    securityMessage = "Use of unrecognized cryptographic hash algorithm."
    or
    // Case for recognized but unapproved algorithms
    not hashAlgorithmName = unknownAlgorithm() and
    securityMessage = "Use of unapproved cryptographic hash algorithm or API: " + hashAlgorithmName + "."
  )
select hashOperation, securityMessage