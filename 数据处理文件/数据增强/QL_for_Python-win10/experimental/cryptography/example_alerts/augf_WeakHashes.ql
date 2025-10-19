/**
 * @name Weak hashes
 * @description Identifies the usage of cryptographic hash algorithms that are either unapproved or considered weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language library and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Select data from HashAlgorithm operations, algorithm names, and warning messages
from HashAlgorithm hashOperation, string algorithmName, string warningMessage
where
  // Extract the hash algorithm name and assign it to the variable 'algorithmName'
  algorithmName = hashOperation.getHashName() and
  // Ensure the algorithm is not one of the approved strong hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate warning message based on whether the algorithm is recognized
  if algorithmName = unknownAlgorithm()
  then warningMessage = "Use of unrecognized hash algorithm."
  else warningMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
select hashOperation, warningMessage