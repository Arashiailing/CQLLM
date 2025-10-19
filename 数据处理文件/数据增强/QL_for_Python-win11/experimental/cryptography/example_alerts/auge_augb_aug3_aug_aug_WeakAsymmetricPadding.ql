/**
 * @name Detection of insecure asymmetric encryption padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically vulnerable or not explicitly verified as secure.
 * This check excludes sanctioned padding techniques (OAEP, KEM, PSS)
 * and highlights all other padding methods as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the collection of sanctioned secure padding techniques
string getSanctionedPaddingAlgorithm() {
  result = ["OAEP", "KEM", "PSS"]
}

// Find asymmetric padding implementations that utilize unsanctioned algorithms
from AsymmetricPadding asymmetricPaddingImpl, string paddingAlgorithm
where
  // Retrieve the padding algorithm name from the implementation
  paddingAlgorithm = asymmetricPaddingImpl.getPaddingName()
  // Exclude implementations that employ sanctioned secure padding algorithms
  and not paddingAlgorithm = getSanctionedPaddingAlgorithm()
select asymmetricPaddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm