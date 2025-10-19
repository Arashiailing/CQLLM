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

// Extract hash operation details including the algorithm name and corresponding alert message
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Retrieve the name of the hash algorithm being used
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved hash algorithms from detection
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate alert message based on whether the algorithm is recognized
  (
    // Case for algorithms that are recognized but unapproved
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case for unrecognized algorithms
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage