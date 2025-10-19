/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies the use of asymmetric encryption padding schemes that are
 * either cryptographically weak or not explicitly recognized as secure.
 * The query specifically filters out approved padding methods (OAEP, KEM, PSS)
 * and highlights any other padding schemes as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Step 1: Identify all asymmetric padding implementations and their algorithm names
from AsymmetricPadding cryptoPadding, string paddingAlgorithm
where
  // Step 2: Extract the padding algorithm name from the implementation
  paddingAlgorithm = cryptoPadding.getPaddingName()
  // Step 3: Exclude known secure padding algorithms (OAEP, KEM, PSS)
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select cryptoPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm