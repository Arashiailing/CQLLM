/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that lack cryptographic strength
 * or are not acknowledged as secure by recognized security standards. This analysis
 * focuses on detecting padding configurations that may introduce security vulnerabilities
 * by only allowing the most secure padding techniques (OAEP, KEM, PSS) and marking
 * all alternatives as potential security threats.
 * 
 * This query specifically targets padding implementations that might be vulnerable
 * to cryptographic attacks when deployed in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define approved padding algorithms for asymmetric encryption
// Only these methods are considered cryptographically secure
from AsymmetricPadding paddingImpl, string paddingName
where
  // Extract the padding algorithm name from the implementation
  paddingName = paddingImpl.getPaddingName()
  // Check if the padding method is not in the approved list
  and not paddingName = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingName