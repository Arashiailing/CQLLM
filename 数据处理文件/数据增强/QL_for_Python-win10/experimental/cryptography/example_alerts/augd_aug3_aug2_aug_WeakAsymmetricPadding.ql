/**
 * @name Detection of vulnerable asymmetric cryptographic padding
 * @description
 * This query identifies implementations of asymmetric cryptographic padding that are
 * considered insecure, obsolete, or without proper security validation. It flags padding
 * algorithms that do not conform to current security best practices, specifically targeting
 * schemes other than the recommended OAEP (Optimal Asymmetric Encryption Padding), 
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme) techniques.
 * Such non-standard padding methods can lead to security flaws including malleability issues,
 * chosen ciphertext attacks, or inadequate entropy, thereby undermining the confidentiality
 * and integrity of cryptographic processes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding algorithms that should be excluded from detection
string securePaddingMethod() { result = ["OAEP", "KEM", "PSS"] }

// Identify asymmetric padding implementations that are not using approved secure methods
from AsymmetricPadding weakPaddingMethod, string algoName
where 
  // Retrieve the algorithm name used in the padding implementation
  algoName = weakPaddingMethod.getPaddingName()
  // Filter out known secure padding algorithms from our results
  and not algoName = securePaddingMethod()
select weakPaddingMethod, "Implementation of unapproved, weak, or unknown asymmetric padding algorithm or API: " + algoName