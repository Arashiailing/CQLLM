/**
 * @name Weak hashes
 * @description Detects cryptographic hash algorithms that are either unapproved or considered weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Find hash operations with weak or unapproved algorithms
from HashAlgorithm hashOp, string algoName, string warningMsg
where
  // Extract the algorithm name from the hash operation
  algoName = hashOp.getHashName() and
  // Filter out strong, approved hash algorithms
  not algoName = ["SHA256", "SHA384", "SHA512"] and
  // Determine the appropriate warning message
  (
    // Handle recognized but unapproved algorithms
    algoName != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + algoName + "."
  )
  or
  (
    // Handle unrecognized algorithms
    algoName = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashOp, warningMsg