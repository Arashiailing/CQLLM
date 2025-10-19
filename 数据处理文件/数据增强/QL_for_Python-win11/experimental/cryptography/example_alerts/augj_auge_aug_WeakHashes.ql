/**
 * @name Weak hashes
 * @description Detects the use of cryptographic hash algorithms that are either unapproved or considered weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Find instances of weak hash algorithm usage and generate appropriate warning messages
from HashAlgorithm hashOperation, string algorithmName, string warningMessage
where
  // Extract the algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  // Define the set of approved strong hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate warning messages based on the algorithm's recognition status
  (
    // Handle recognized but unapproved algorithms
    algorithmName != "" and
    warningMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Handle unrecognized algorithms
    algorithmName = "" and
    warningMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, warningMessage