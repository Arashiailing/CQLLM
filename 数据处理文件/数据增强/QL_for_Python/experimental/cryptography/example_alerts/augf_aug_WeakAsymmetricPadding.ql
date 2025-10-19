/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * Identifies cryptographic operations that utilize asymmetric padding algorithms which are
 * considered weak, unapproved, or have unknown security properties. Approved secure
 * asymmetric padding schemes include OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * The use of other padding schemes may introduce security vulnerabilities in cryptographic implementations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding instances that use insecure or unknown algorithms
from AsymmetricPadding insecurePadding, string paddingAlgorithmName
where 
  // Extract the name of the padding algorithm being used
  paddingAlgorithmName = insecurePadding.getPaddingName()
  // Check if the padding algorithm is not in the set of approved secure algorithms
  and not (paddingAlgorithmName = "OAEP" or paddingAlgorithmName = "KEM" or paddingAlgorithmName = "PSS")
select insecurePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName