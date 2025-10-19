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

// Define approved strong hash algorithms as a constant list
string strongHashAlgo() { result = ["SHA256", "SHA384", "SHA512"].toString() }

// Select data from HashAlgorithm operations, algorithm names, and alert messages
from HashAlgorithm hashFuncCall, string hashAlgoName, string alertMessage
where
  // Extract the hash algorithm name from the operation
  hashAlgoName = hashFuncCall.getHashName() and
  // Check if the algorithm is not in the approved strong hash list
  not hashAlgoName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate alert message based on algorithm recognition status
  (
    // Case for unrecognized algorithms
    hashAlgoName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized hash algorithm."
    or
    // Case for recognized but unapproved algorithms
    not hashAlgoName = unknownAlgorithm() and
    alertMessage = "Use of unapproved hash algorithm or API " + hashAlgoName + "."
  )
select hashFuncCall, alertMessage