/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding mechanisms that are either
 * cryptographically weak or not explicitly confirmed as secure.
 * 
 * Proper padding is essential for asymmetric encryption security. This analysis
 * identifies padding schemes known to be vulnerable or not recognized as secure
 * methods. The query explicitly excludes approved padding techniques (OAEP, KEM, PSS)
 * which are cryptographically sound, and marks all other padding mechanisms as
 * potential security concerns.
 * 
 * Employment of weak or unidentified padding schemes can result in security flaws
 * including padding oracle attacks, enabling attackers to decrypt encrypted data
 * without possessing the private key.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically approved padding methods
string approvedPaddingMethods() {
  result = ["OAEP", "KEM", "PSS"]
}

// Identify asymmetric padding implementations using non-approved algorithms
from AsymmetricPadding paddingImplementation, string paddingScheme
where
  // Extract the padding scheme name from the implementation
  paddingScheme = paddingImplementation.getPaddingName()
  // Verify the padding scheme is not in the approved methods list
  and not paddingScheme = approvedPaddingMethods()
select paddingImplementation, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme