/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * This check excludes secure padding methods (OAEP, KEM, PSS) and identifies
 * all other padding schemes as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// List of cryptographically secure padding schemes that are considered safe
string approvedPaddingScheme() {
  result = ["OAEP", "KEM", "PSS"]
}

// Query to find asymmetric padding implementations using unapproved schemes
from AsymmetricPadding paddingImpl, string schemeName
where
  // Extract the padding scheme name from the implementation
  schemeName = paddingImpl.getPaddingName()
  // Filter out implementations using approved secure padding schemes
  and schemeName != approvedPaddingScheme()
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + schemeName