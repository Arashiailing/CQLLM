/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * Identifies cryptographic implementations using asymmetric padding algorithms that are
 * considered weak, unapproved, or have unknown security properties. Approved secure schemes
 * include OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme). Other padding schemes may introduce vulnerabilities
 * such as padding oracle attacks, malleability issues, or weak randomness properties.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding algorithms that are not approved
from AsymmetricPadding weakPaddingAlgorithm, string paddingAlgorithmName
where 
  // Get the name of the padding algorithm
  paddingAlgorithmName = weakPaddingAlgorithm.getPaddingName()
  // Ensure the padding algorithm is not among the approved secure schemes
  and not paddingAlgorithmName = "OAEP"
  and not paddingAlgorithmName = "KEM"
  and not paddingAlgorithmName = "PSS"
select weakPaddingAlgorithm, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName