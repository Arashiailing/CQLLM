/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding mechanisms that are either
 * cryptographically weak or not explicitly confirmed as secure.
 * 
 * Asymmetric encryption necessitates appropriate padding for security. This query
 * identifies padding schemes that are recognized as insecure or are not established
 * as secure padding techniques. The analysis specifically excludes approved
 * padding methods (OAEP, KEM, PSS) which are regarded as cryptographically
 * secure, and marks all other padding schemes as possible security threats.
 * 
 * Employing weak or unidentified padding schemes can result in vulnerabilities
 * such as padding oracle attacks, enabling attackers to decrypt encrypted data
 * without possessing the private key.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of secure padding algorithms considered safe
string getSecurePaddingMethods() {
  result = ["OAEP", "KEM", "PSS"]
}

// Identify asymmetric padding implementations using non-secure algorithms
from AsymmetricPadding paddingImpl
where
  // Extract the padding algorithm name from the implementation
  exists(string paddingMethod |
    paddingMethod = paddingImpl.getPaddingName()
    // Verify that the padding algorithm is not among the secure schemes
    and not paddingMethod = getSecurePaddingMethods()
  )
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingImpl.getPaddingName()