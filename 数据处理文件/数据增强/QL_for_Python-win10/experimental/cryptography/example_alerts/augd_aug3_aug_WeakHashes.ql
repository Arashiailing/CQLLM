/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash functions that are either unapproved 
 *              or considered weak for security purposes.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python language constructs and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Identify cryptographic hash operations that utilize weak or unapproved algorithms
from HashAlgorithm hashOperation, string algoName, string alertMessage
where
  // Extract the algorithm name from the hash operation
  algoName = hashOperation.getHashName() and
  // Exclude approved strong hash algorithms from detection
  not algoName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate alert message based on algorithm recognition status
  (
    // Case 1: Algorithm is recognized but unapproved
    algoName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algoName + "."
  )
  or
  (
    // Case 2: Algorithm is unrecognized
    algoName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage