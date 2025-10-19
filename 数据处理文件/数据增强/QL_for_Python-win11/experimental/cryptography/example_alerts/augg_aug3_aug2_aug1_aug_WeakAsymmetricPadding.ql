/**
 * @name Detection of weak or unknown asymmetric padding
 * @description Flags asymmetric cryptographic padding algorithms that are either
 * known to be weak, not approved for secure use, or have unknown security properties.
 * Only OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) are considered secure. All other padding
 * methods may introduce security vulnerabilities and should be replaced with approved schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify insecure asymmetric padding implementations
from AsymmetricPadding unsafePadding, string paddingAlgorithmName
where 
  // Extract padding algorithm name
  paddingAlgorithmName = unsafePadding.getPaddingName()
  // Exclude approved secure padding schemes
  and paddingAlgorithmName != "OAEP"
  and paddingAlgorithmName != "KEM"
  and paddingAlgorithmName != "PSS"
select unsafePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName