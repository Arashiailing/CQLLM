/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies cryptographic implementations using unapproved, weak, or unknown 
 * asymmetric padding schemes. Only OAEP, KEM, and PSS padding schemes are 
 * considered secure for asymmetric cryptography. All other padding methods 
 * may introduce vulnerabilities and should be avoided.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding schemes as a constant list
// Only these padding schemes are considered cryptographically secure
from AsymmetricPadding paddingScheme, string paddingName
where
  // Extract the padding scheme name from the cryptographic implementation
  paddingName = paddingScheme.getPaddingName() and
  // Verify the padding scheme is not in the approved secure list
  not paddingName in ["OAEP", "KEM", "PSS"]
select paddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName