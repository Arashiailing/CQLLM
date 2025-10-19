/**
 * @name Weak cryptographic hash algorithms
 * @description This query detects the usage of cryptographic hash algorithms that are either
 *              not approved for security purposes or are considered cryptographically weak.
 *              It helps identify potential security vulnerabilities in cryptographic implementations.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary modules for Python language analysis and cryptographic security concepts
import python
import experimental.cryptography.Concepts

// Query to identify weak cryptographic hash operations and generate corresponding security alerts
from HashAlgorithm hashOp, string hashAlgorithmName, string alertMessage
where
  // Extract the name of the cryptographic hash algorithm from the operation
  hashAlgorithmName = hashOp.getHashName() and
  // Define the set of approved strong cryptographic hash algorithms
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Determine if the algorithm is unrecognized or simply unapproved
  (
    // Case 1: Algorithm is not recognized by the cryptographic framework
    hashAlgorithmName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized cryptographic hash algorithm."
    or
    // Case 2: Algorithm is recognized but not on the approved list
    not hashAlgorithmName = unknownAlgorithm() and
    alertMessage = "Use of unapproved cryptographic hash algorithm or API: " + hashAlgorithmName + "."
  )
// Select the hash operation and the corresponding security alert message
select hashOp, alertMessage