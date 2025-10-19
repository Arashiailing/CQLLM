/**
 * @name Detection of insecure asymmetric cryptographic padding
 * @description
 * Identifies asymmetric encryption padding techniques that are known to be vulnerable,
 * deprecated for security-critical applications, or lack sufficient security validation.
 * The query flags any padding implementation other than OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), or PSS (Probabilistic Signature Scheme), which are the only
 * padding methods considered cryptographically secure for asymmetric operations.
 * Using alternative padding schemes may expose cryptographic systems to various attacks and
 * should be replaced with standardized secure algorithms.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure padding algorithms
// Only these padding schemes are considered cryptographically strong
string securePaddingScheme() {
  result in ["OAEP", "KEM", "PSS"]
}

// Detect implementations of asymmetric cryptographic padding that are not secure
from AsymmetricPadding insecurePaddingMethod, string paddingAlgorithmName
where 
  // Retrieve the name of the padding algorithm being used
  paddingAlgorithmName = insecurePaddingMethod.getPaddingName()
  // Verify that the padding algorithm is not in the approved secure set
  and paddingAlgorithmName != securePaddingScheme()
select insecurePaddingMethod, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName