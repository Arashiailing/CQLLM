/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This analysis identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. The query flags potentially vulnerable padding configurations
 * by allowing only the most secure padding methods (OAEP, KEM, PSS) and marking
 * all other schemes as potential security risks.
 * 
 * The analysis specifically targets padding implementations that may be vulnerable
 * to cryptographic attacks in asymmetric encryption contexts. Using insecure padding
 * can lead to various attacks including chosen ciphertext attacks, padding oracle
 * attacks, and other cryptographic vulnerabilities.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes for asymmetric encryption
// Only these specific padding techniques are considered secure according to current standards
from AsymmetricPadding paddingScheme, string paddingAlgorithmName
where
  // Extract the name of the padding algorithm from the implementation
  paddingAlgorithmName = paddingScheme.getPaddingName()
  // Verify that the padding method is not in the approved list of secure schemes
  and not paddingAlgorithmName = ["OAEP", "KEM", "PSS"]
select paddingScheme, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithmName