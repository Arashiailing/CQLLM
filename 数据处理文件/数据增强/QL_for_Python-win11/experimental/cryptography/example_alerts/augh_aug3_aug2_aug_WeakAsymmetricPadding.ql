/**
 * @name Identification of insecure asymmetric cryptographic padding
 * @description
 * This query identifies asymmetric cryptographic padding schemes that are considered insecure,
 * deprecated, or lacking proper security validation. It flags padding algorithms that do not
 * conform to established security standards, specifically targeting schemes other than the
 * recommended OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) methods. Using non-standard padding can lead to
 * vulnerabilities including malleability, chosen ciphertext attacks, or insufficient entropy,
 * which may compromise the confidentiality and integrity of cryptographic operations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric padding implementations that use non-approved algorithms
from AsymmetricPadding weakPadding, string algorithmName
where 
  // Retrieve the name of the padding algorithm in use
  algorithmName = weakPadding.getPaddingName()
  // Filter out results that use approved secure padding methods
  and not algorithmName = ["OAEP", "KEM", "PSS"]
select weakPadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + algorithmName