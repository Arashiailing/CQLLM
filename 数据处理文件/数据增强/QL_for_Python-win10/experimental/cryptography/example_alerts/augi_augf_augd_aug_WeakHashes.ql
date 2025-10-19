/**
 * @name Weak cryptographic hash algorithms detection
 * @description Identifies the usage of cryptographic hash algorithms that are either unapproved or considered weak for security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python analysis libraries and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Identify weak hash algorithm usage and generate corresponding security warnings
from HashAlgorithm hashUsage, string hashAlgorithmName, string warningMessage
where
  // Extract the algorithm name from the hash operation
  hashAlgorithmName = hashUsage.getHashName() and
  
  // Filter out cryptographically strong hash algorithms
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  
  // Generate appropriate security warning based on algorithm recognition status
  (
    // Case 1: Algorithm is recognized but not approved for secure use
    hashAlgorithmName != "" and
    warningMessage = "Use of unapproved hash algorithm or API " + hashAlgorithmName + "."
  )
  or
  (
    // Case 2: Algorithm is not recognized, potentially indicating a custom or obscure implementation
    hashAlgorithmName = "" and
    warningMessage = "Use of unrecognized hash algorithm."
  )
select hashUsage, warningMessage