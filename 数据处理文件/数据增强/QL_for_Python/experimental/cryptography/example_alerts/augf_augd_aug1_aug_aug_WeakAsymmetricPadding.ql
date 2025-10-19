/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by
 * established security standards. This analysis excludes known secure
 * padding methods (OAEP, KEM, PSS) and flags all other padding schemes
 * as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define a predicate that returns the list of cryptographically secure padding schemes
string getSecurePaddingSchemes() {
  result = ["OAEP", "KEM", "PSS"]
}

// Main query to detect asymmetric encryption implementations using insecure padding
from AsymmetricPadding asymmetricPadding, string paddingScheme
where
  // Extract the name of the padding scheme being used
  paddingScheme = asymmetricPadding.getPaddingName()
  // Ensure the padding scheme is not one of the approved secure methods
  and paddingScheme != getSecurePaddingSchemes()
select asymmetricPadding, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingScheme