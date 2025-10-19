/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of deprecated or insecure cryptographic hash functions
 *              in security-sensitive contexts.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python libraries and cryptographic analysis modules
import python
import experimental.cryptography.Concepts

// Define strong hash algorithms that are considered secure
string secureAlgorithm() {
  result = ["SHA256", "SHA384", "SHA512"]
}

// Detect cryptographic hash operations that use weak algorithms
from HashAlgorithm hashOperation, string algorithmName, string warningMessage
where
  // Extract the name of the hash algorithm being used
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved cryptographic hash algorithms
  not algorithmName = secureAlgorithm() and
  // Generate appropriate security warning based on algorithm identification
  (
    // Case: Algorithm is identified but not approved
    algorithmName != "" and
    warningMessage = "Detected unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case: Algorithm cannot be identified
    algorithmName = "" and
    warningMessage = "Detected unrecognized hash algorithm."
  )
select hashOperation, warningMessage