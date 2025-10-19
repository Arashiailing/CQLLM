/**
 * @name Weak cryptographic hash functions
 * @description Detects the use of cryptographic hash algorithms that are either unapproved or considered weak for security purposes.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and experimental cryptography analysis components
import python
import experimental.cryptography.Concepts

// Define approved strong hash algorithms as a constant set
string getApprovedAlgorithm() { 
  result = ["SHA256", "SHA384", "SHA512"] 
}

from HashAlgorithm cryptoHash, string algorithmName, string securityWarning
where
  // Extract the algorithm name from the hash operation
  algorithmName = cryptoHash.getHashName() and
  // Filter out approved strong hash algorithms
  not algorithmName = getApprovedAlgorithm() and
  // Generate appropriate security warning based on algorithm recognition status
  (
    // Case for recognized but unapproved algorithms
    algorithmName != "" and
    securityWarning = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case for unrecognized algorithms
    algorithmName = "" and
    securityWarning = "Use of unrecognized hash algorithm."
  )
select cryptoHash, securityWarning