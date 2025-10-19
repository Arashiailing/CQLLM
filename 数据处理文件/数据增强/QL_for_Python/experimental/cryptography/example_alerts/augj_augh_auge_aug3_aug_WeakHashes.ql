/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of deprecated or insecure cryptographic hash functions
 *              that should not be used in security-sensitive contexts.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary modules for Python language support and cryptographic analysis
import python
import experimental.cryptography.Concepts

// Define the query to detect weak cryptographic hash algorithms
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Extract the name of the hash algorithm being used
  algorithmName = hashOperation.getHashName() and
  
  // Filter out strong, approved hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  
  // Generate appropriate alert message based on the algorithm status
  (
    // Case: Algorithm is recognized but not in the approved list
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case: Algorithm is not recognized
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage