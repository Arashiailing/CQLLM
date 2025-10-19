/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically insecure or not explicitly verified as secure.
 * 
 * Asymmetric encryption requires proper padding to be secure. This query
 * detects padding schemes that are known to be weak or are not recognized
 * as secure padding methods. The analysis specifically excludes approved
 * padding methods (OAEP, KEM, PSS) which are considered cryptographically
 * secure, and flags all other padding schemes as potential security risks.
 * 
 * Using weak or unknown padding schemes can lead to vulnerabilities such as
 * padding oracle attacks, which can allow attackers to decrypt encrypted data
 * without knowing the private key.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the collection of secure padding algorithms that are considered safe
string securePaddingSchemes() {
  result = ["OAEP", "KEM", "PSS"]
}

// Find asymmetric padding implementations that utilize non-secure algorithms
from AsymmetricPadding asymmetricPadding, string paddingAlgorithm
where
  // Retrieve the padding algorithm name from the implementation
  paddingAlgorithm = asymmetricPadding.getPaddingName()
  // Check if the padding algorithm is not in the list of secure schemes
  and not paddingAlgorithm = securePaddingSchemes()
select asymmetricPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm