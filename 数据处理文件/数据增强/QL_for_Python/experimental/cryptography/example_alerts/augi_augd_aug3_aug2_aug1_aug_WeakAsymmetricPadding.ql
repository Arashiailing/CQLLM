/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This query identifies asymmetric cryptographic padding algorithms that are considered
 * weak, not approved for secure use, or have unknown security characteristics.
 * Only OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) are recognized as secure for asymmetric cryptography.
 * Any other padding method may introduce security vulnerabilities and should be replaced
 * with approved schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure padding schemes for asymmetric cryptography
string getApprovedSecurePadding() {
  result in ["OAEP", "KEM", "PSS"]
}

// Find instances of asymmetric padding that are not in the approved secure set
from AsymmetricPadding vulnerablePadding, string paddingName
where 
  // Extract the name of the padding algorithm being used
  paddingName = vulnerablePadding.getPaddingName()
  // Verify that the padding algorithm is not among the approved secure schemes
  and paddingName != getApprovedSecurePadding()
select vulnerablePadding, "Detected use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName