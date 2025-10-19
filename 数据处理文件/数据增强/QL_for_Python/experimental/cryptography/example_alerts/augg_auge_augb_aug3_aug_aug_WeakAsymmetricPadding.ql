/**
 * @name Insecure Asymmetric Encryption Padding Detection
 * @description
 * This query identifies asymmetric encryption padding mechanisms that are
 * either cryptographically weak or not explicitly confirmed as secure.
 * The analysis excludes approved padding schemes (OAEP, KEM, PSS) and
 * flags all other padding methods as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the collection of approved secure padding schemes
string getApprovedPaddingScheme() {
  result = ["OAEP", "KEM", "PSS"]
}

// Identify asymmetric padding implementations that use unapproved schemes
from AsymmetricPadding paddingImplementation, string paddingScheme
where
  // Extract the padding scheme name from the implementation
  paddingScheme = paddingImplementation.getPaddingName()
  // Filter out implementations that use approved secure padding schemes
  and not paddingScheme = getApprovedPaddingScheme()
select paddingImplementation, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme