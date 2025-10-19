/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either cryptographically weak
 * or not explicitly recognized as secure. This analysis excludes approved padding methods
 * (OAEP, KEM, PSS) and flags all other padding schemes as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding schemes that should be excluded from detection
string securePaddingScheme() {
  result = ["OAEP", "KEM", "PSS"]
}

// Identify all asymmetric padding implementations and analyze their security
from AsymmetricPadding paddingImpl, string paddingScheme
where
  // Extract the padding algorithm name from the implementation
  paddingScheme = paddingImpl.getPaddingName()
  // Filter out known secure padding algorithms
  and not paddingScheme = securePaddingScheme()
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme