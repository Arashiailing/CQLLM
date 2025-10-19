/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * This analysis excludes secure padding methods (OAEP, KEM, PSS) and flags
 * all other padding schemes as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding schemes that should be excluded from detection
string secureScheme() {
  result = ["OAEP", "KEM", "PSS"]
}

// Identify asymmetric padding implementations and analyze their scheme names
from AsymmetricPadding asymmetricPaddingInstance, string paddingSchemeName
where
  // Retrieve the padding scheme name from the implementation
  paddingSchemeName = asymmetricPaddingInstance.getPaddingName()
  // Exclude known secure padding schemes from detection
  and paddingSchemeName != secureScheme()
select asymmetricPaddingInstance, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingSchemeName