/**
 * @name Identification of insecure asymmetric cryptographic padding
 * @description
 * This query detects the usage of asymmetric cryptographic padding schemes that are
 * deemed insecure, outdated, or lacking appropriate security verification. It highlights
 * padding algorithms that deviate from contemporary security standards, with a focus on
 * identifying implementations that do not utilize recommended approaches such as OAEP 
 * (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism), and PSS 
 * (Probabilistic Signature Scheme). These suboptimal padding techniques may introduce
 * vulnerabilities including malleability concerns, chosen ciphertext attacks, or insufficient
 * randomness, thus compromising the confidentiality and integrity of cryptographic operations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define approved padding schemes that meet security requirements
string approvedPaddingScheme() { result = ["OAEP", "KEM", "PSS"] }

// Identify asymmetric padding implementations that use non-approved methods
from AsymmetricPadding insecurePaddingImplementation, string paddingAlgorithmName
where 
  // Extract the name of the padding algorithm being used
  paddingAlgorithmName = insecurePaddingImplementation.getPaddingName()
  // Ensure the algorithm is not in our list of approved schemes
  and not paddingAlgorithmName = approvedPaddingScheme()
select insecurePaddingImplementation, "Implementation of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName