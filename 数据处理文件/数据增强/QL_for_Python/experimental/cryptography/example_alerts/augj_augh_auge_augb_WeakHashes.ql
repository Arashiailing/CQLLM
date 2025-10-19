/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies cryptographic hash functions that are either not approved
 *              for security purposes or are considered cryptographically weak.
 *              This query helps detect potential security vulnerabilities in
 *              cryptographic implementations by flagging the use of insecure hashing.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary modules for Python language analysis and cryptographic security concepts
import python
import experimental.cryptography.Concepts

// Define the set of cryptographically strong hash algorithms approved for security use
string approvedStrongHashAlgorithm() {
  result in ["SHA256", "SHA384", "SHA512"]
}

// Query to identify weak cryptographic hash operations and generate corresponding security alerts
from HashAlgorithm cryptoHashOperation, string hashName, string securityAlert
where
  // Extract the name of the cryptographic hash algorithm from the operation
  hashName = cryptoHashOperation.getHashName() and
  // Check if the algorithm is not in the approved list of strong hash algorithms
  not hashName = approvedStrongHashAlgorithm() and
  // Generate appropriate security alert based on algorithm recognition status
  (
    // Case 1: Algorithm is not recognized by the cryptographic framework
    hashName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized cryptographic hash algorithm."
    or
    // Case 2: Algorithm is recognized but not on the approved list
    not hashName = unknownAlgorithm() and
    securityAlert = "Use of unapproved cryptographic hash algorithm or API: " + hashName + "."
  )
// Select the hash operation and the corresponding security alert message
select cryptoHashOperation, securityAlert