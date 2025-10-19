/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of cryptographic hash functions that are either
 *              deprecated or considered insecure for security-sensitive applications.
 *              This query flags hash algorithms that are not within the approved
 *              strong algorithm set (SHA256, SHA384, SHA512) or cannot be
 *              properly identified by the analysis.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python modules and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Identify cryptographic hash operations that utilize weak or non-approved algorithms
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Extract the name of the hash algorithm being utilized
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved hash algorithms from detection
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security alert based on algorithm recognition status
  (
    // Case 1: Algorithm is recognized but not in the approved list
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
    or
    // Case 2: Algorithm cannot be recognized by the analysis
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage