/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash algorithms that are either unapproved or considered weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python libraries and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Identify weak hash operations and generate corresponding security alerts
from HashAlgorithm hashOp, string algoName, string warningMsg
where
  // Extract algorithm name from hash operation
  algoName = hashOp.getHashName() and
  // Exclude strong, approved hash algorithms
  not algoName in ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate warning based on algorithm recognition
  (
    // Case for recognized but unapproved algorithms
    algoName != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + algoName + "."
  )
  or
  (
    // Case for unrecognized algorithms
    algoName = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashOp, warningMsg