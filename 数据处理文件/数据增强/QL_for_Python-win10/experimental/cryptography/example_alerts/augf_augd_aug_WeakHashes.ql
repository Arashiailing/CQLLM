/**
 * @name Weak hashes
 * @description Identifies the usage of cryptographic hash algorithms that are either unapproved or considered weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python libraries and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Detect weak hash algorithm usage and generate appropriate security warnings
from HashAlgorithm hashOperation, string algorithmName, string securityWarning
where
  // Extract the algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  
  // Filter out cryptographically strong hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  
  // Generate appropriate security warning based on algorithm recognition status
  (
    // Scenario: Algorithm is recognized but not approved
    algorithmName != "" and
    securityWarning = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Scenario: Algorithm is not recognized
    algorithmName = "" and
    securityWarning = "Use of unrecognized hash algorithm."
  )
select hashOperation, securityWarning