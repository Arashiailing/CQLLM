/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash functions that are unsuitable
 *              for security purposes or are considered cryptographically broken.
 *              This analysis helps identify potential vulnerabilities in cryptographic implementations.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary modules for Python code analysis and cryptographic security evaluation
import python
import experimental.cryptography.Concepts

// Analysis to identify weak cryptographic hash functions and generate appropriate security warnings
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Retrieve the name of the hash algorithm being used
  algorithmName = hashOperation.getHashName() and
  // Verify that the algorithm is not among the approved secure hash functions
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Construct appropriate alert message based on algorithm recognition status
  (
    // Case for unrecognized hash algorithms
    algorithmName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized cryptographic hash algorithm."
    or
    // Case for recognized but insecure hash algorithms
    not algorithmName = unknownAlgorithm() and
    alertMessage = "Use of unapproved cryptographic hash algorithm or API: " + algorithmName + "."
  )
// Report the identified hash operation with corresponding security alert
select hashOperation, alertMessage