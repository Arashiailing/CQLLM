/**
 * @name Detection of vulnerable asymmetric cryptographic padding
 * @description
 * Identifies asymmetric cryptographic padding implementations that are considered insecure,
 * obsolete, or lacking proper security validation. This query flags padding algorithms that
 * deviate from current security best practices, specifically targeting schemes other than
 * the recommended OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) techniques. Non-standard padding methods can introduce
 * security vulnerabilities such as malleability issues, chosen ciphertext attacks, or insufficient
 * entropy, compromising the confidentiality and integrity of cryptographic operations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding algorithms that are considered safe
string approvedPaddingScheme() { result = ["OAEP", "KEM", "PSS"] }

// Query to detect asymmetric padding implementations that do not use approved secure methods
from AsymmetricPadding insecurePaddingImplementation, string paddingAlgorithmName
where 
  // Extract the name of the padding algorithm being used
  paddingAlgorithmName = insecurePaddingImplementation.getPaddingName()
  // Ensure the detected padding algorithm is not in the list of approved secure schemes
  and not paddingAlgorithmName = approvedPaddingScheme()
select insecurePaddingImplementation, "Implementation of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName