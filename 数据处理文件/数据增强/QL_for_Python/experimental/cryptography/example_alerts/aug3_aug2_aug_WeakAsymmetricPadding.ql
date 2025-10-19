/**
 * @name Identification of insecure asymmetric cryptographic padding
 * @description
 * Detects the implementation of asymmetric cryptographic padding schemes that are considered
 * weak, deprecated, or lacking sufficient security validation. The query identifies padding
 * algorithms that deviate from established security standards, focusing on schemes other than
 * the recommended OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) methods. These alternative padding approaches may
 * introduce vulnerabilities such as malleability, chosen ciphertext attacks, or insufficient
 * entropy, potentially compromising the confidentiality and integrity of cryptographic operations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding schemes that are not among the approved secure methods
from AsymmetricPadding insecurePaddingScheme, string paddingAlgorithmName
where 
  // Extract the name of the padding algorithm being used
  paddingAlgorithmName = insecurePaddingScheme.getPaddingName()
  // Exclude known secure padding algorithms from the results
  and not paddingAlgorithmName = ["OAEP", "KEM", "PSS"]
select insecurePaddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName