/**
 * @name Identification of insecure asymmetric cryptographic padding
 * @description
 * This query detects the usage of asymmetric padding algorithms that are either weak, not approved, or have unknown security properties.
 * Recommended secure asymmetric padding methods include OAEP, KEM, and PSS; alternative padding schemes may present security risks.
 * Highlighting these insecure padding practices helps mitigate potential cryptographic vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding schemes that are not among the approved secure methods
from AsymmetricPadding cryptoPadding, string schemeName
where 
  // Extract the name of the padding scheme being used
  schemeName = cryptoPadding.getPaddingName()
  // Exclude known secure padding schemes from the results
  and not schemeName = ["OAEP", "KEM", "PSS"]
select cryptoPadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + schemeName