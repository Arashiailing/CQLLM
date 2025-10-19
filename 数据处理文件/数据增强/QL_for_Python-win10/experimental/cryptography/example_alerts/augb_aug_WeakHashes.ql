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

// Extract hash operation details including the algorithm name and corresponding warning message
from HashAlgorithm hashOp, string hashAlgoName, string warningMsg
where
  // Retrieve the name of the hash algorithm being used
  hashAlgoName = hashOp.getHashName() and
  // Exclude strong, approved hash algorithms from detection
  not hashAlgoName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate warning message based on whether the algorithm is recognized
  (
    // Case for algorithms that are recognized but unapproved
    hashAlgoName != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + hashAlgoName + "."
  )
  or
  (
    // Case for unrecognized algorithms
    hashAlgoName = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashOp, warningMsg