/**
 * @name Insecure cryptographic hash function usage
 * @description Identifies applications utilizing cryptographic hash algorithms that 
 *              are either not approved or known to be weak for security-sensitive operations.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python language constructs and cryptographic analysis definitions
import python
import experimental.cryptography.Concepts

// Detect cryptographic hash operations using weak or unapproved algorithms
from HashAlgorithm hashOperation, string algorithmName, string warningMessage
where
  // Obtain the algorithm identifier from the hash operation
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, approved hash algorithms from detection
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on algorithm status
  (
    // Case for recognized but unapproved algorithms
    algorithmName != "" and
    warningMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case for unrecognized or empty algorithm identifiers
    algorithmName = "" and
    warningMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, warningMessage