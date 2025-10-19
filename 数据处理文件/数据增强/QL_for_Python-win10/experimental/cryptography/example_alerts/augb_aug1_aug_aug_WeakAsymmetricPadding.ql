/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding methods that are considered
 * cryptographically insecure or not explicitly recognized as secure
 * by established security guidelines. This check specifically filters out
 * approved padding techniques (OAEP, KEM, PSS) and highlights
 * any other padding methods as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// List of cryptographically secure padding schemes that are considered safe
string approvedPaddingSchemes() {
  result = ["OAEP", "KEM", "PSS"]
}

// Find all asymmetric padding implementations and check if they use approved schemes
from AsymmetricPadding paddingImpl, string schemeName
where
  // Extract the name of the padding scheme from the implementation
  schemeName = paddingImpl.getPaddingName()
  // Filter out implementations that use approved padding schemes
  and schemeName != approvedPaddingSchemes()
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + schemeName