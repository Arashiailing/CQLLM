/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This query identifies instances where asymmetric padding algorithms that are considered 
 * weak, unapproved, or have unknown security properties are being used. The only secure 
 * asymmetric padding schemes that should be used are OAEP, KEM, and PSS. Any other 
 * padding scheme could potentially introduce security vulnerabilities and should be avoided.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure padding schemes
// These are the only padding algorithms considered safe for asymmetric cryptography
string approvedPaddingScheme() {
  result = "OAEP" or result = "KEM" or result = "PSS"
}

// Find all instances of asymmetric padding that are not in the approved list
from AsymmetricPadding insecurePaddingScheme, string paddingName
where 
  // Extract the name of the padding algorithm being used
  paddingName = insecurePaddingScheme.getPaddingName()
  // Check if the padding algorithm is not one of the approved secure schemes
  and paddingName != approvedPaddingScheme()
select insecurePaddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName