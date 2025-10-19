/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
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

// Define the collection of cryptographically secure padding algorithms
string securePaddingMethods() {
  result = ["OAEP", "KEM", "PSS"]
}

// Locate asymmetric padding implementations utilizing non-secure methods
from AsymmetricPadding paddingInstance, string paddingMethod
where
  // Retrieve the padding method name from the implementation
  paddingMethod = paddingInstance.getPaddingName()
  // Exclude implementations that employ approved secure padding methods
  and not paddingMethod = securePaddingMethods()
select paddingInstance, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingMethod