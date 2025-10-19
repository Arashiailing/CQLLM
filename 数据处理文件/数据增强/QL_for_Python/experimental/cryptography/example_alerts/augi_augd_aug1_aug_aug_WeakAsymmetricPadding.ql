/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically insecure or not explicitly recognized as secure by
 * established security standards. This analysis specifically excludes
 * known secure padding methods (OAEP, KEM, PSS) and flags any other
 * padding techniques as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Collection of padding schemes that are recognized as cryptographically secure
string securePaddingMethods() {
  result = ["OAEP", "KEM", "PSS"]
}

// Analysis to detect asymmetric encryption padding implementations
// that utilize padding schemes not included in the secure methods list
from AsymmetricPadding paddingImplementation, string paddingSchemeName
where
  // Obtain the name of the padding scheme from the implementation
  paddingSchemeName = paddingImplementation.getPaddingName()
  // Exclude implementations that use approved secure padding schemes
  and paddingSchemeName != securePaddingMethods()
select paddingImplementation, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingSchemeName