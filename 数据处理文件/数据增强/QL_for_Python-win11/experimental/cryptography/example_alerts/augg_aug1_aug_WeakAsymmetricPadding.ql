/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This analysis identifies cryptographic implementations that utilize asymmetric padding algorithms
 * which are considered cryptographically weak, unapproved for security-sensitive applications,
 * or have unknown security properties. The analysis specifically checks for the absence of
 * approved secure asymmetric padding schemes such as OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme). Any other padding
 * schemes may introduce significant security vulnerabilities including but not limited to padding
 * oracle attacks, malleability issues, or weak randomness properties, and should be avoided in
 * security-critical applications.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// This query detects the use of asymmetric padding algorithms that are not approved
// for security-sensitive applications. Approved schemes include OAEP, KEM, and PSS.
// All other padding schemes should be considered potentially insecure.

// Identify instances of asymmetric padding algorithms
from AsymmetricPadding insecurePaddingScheme, string paddingSchemeName
where 
  // Extract the name of the padding algorithm being used
  paddingSchemeName = insecurePaddingScheme.getPaddingName()
  // Filter out approved secure padding schemes
  and paddingSchemeName != "OAEP"
  and paddingSchemeName != "KEM"
  and paddingSchemeName != "PSS"
select insecurePaddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingSchemeName