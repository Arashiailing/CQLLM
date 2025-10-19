/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are considered
 * cryptographically weak or not explicitly approved as secure.
 * This analysis excludes recognized secure padding methods (OAEP, KEM, PSS)
 * and highlights any alternative padding schemes as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric padding implementations and extract their algorithm identifiers
from AsymmetricPadding asymmetricPadding, string paddingAlgorithm
where
  // Obtain the padding algorithm identifier from the implementation
  paddingAlgorithm = asymmetricPadding.getPaddingName()
  // Filter out known secure padding algorithms (OAEP, KEM, PSS)
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select asymmetricPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm