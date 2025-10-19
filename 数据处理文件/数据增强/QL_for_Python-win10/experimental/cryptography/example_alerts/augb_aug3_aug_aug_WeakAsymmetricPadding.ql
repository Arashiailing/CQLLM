/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure.
 * This analysis excludes approved padding methods (OAEP, KEM, PSS)
 * and flags all other padding schemes as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure padding algorithms
string approvedPaddingScheme() {
  result = ["OAEP", "KEM", "PSS"]
}

// Identify asymmetric padding implementations that use non-approved schemes
from AsymmetricPadding paddingImpl, string paddingScheme
where
  // Extract the padding scheme name from the implementation
  paddingScheme = paddingImpl.getPaddingName()
  // Filter out implementations using approved secure padding schemes
  and not paddingScheme = approvedPaddingScheme()
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme