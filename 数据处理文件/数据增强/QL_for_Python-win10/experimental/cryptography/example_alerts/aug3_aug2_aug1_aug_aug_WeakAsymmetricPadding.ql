/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either cryptographically 
 * insecure or not explicitly recognized by established security standards. This analysis 
 * targets padding implementations that do not adhere to industry best practices, 
 * specifically excluding well-vetted secure methods such as OAEP (Optimal Asymmetric 
 * Encryption Padding), KEM (Key Encapsulation Mechanism), and PSS (Probabilistic 
 * Signature Scheme).
 * 
 * Padding schemes not included in the approved list are flagged as potential security
 * vulnerabilities, which may lead to cryptographic weaknesses including chosen ciphertext
 * attacks, padding oracle attacks, or inadequate randomness in encryption operations.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Predicate that returns all cryptographically secure and approved padding schemes
string getApprovedPaddingSchemes() {
  result = ["OAEP", "KEM", "PSS"]
}

// Predicate to check if a padding implementation uses an unapproved scheme
predicate isUnapprovedPaddingScheme(AsymmetricPadding paddingInstance, string paddingSchemeName) {
  paddingSchemeName = paddingInstance.getPaddingName()
  and paddingSchemeName != getApprovedPaddingSchemes()
}

// Query to identify asymmetric padding implementations using unapproved schemes
from AsymmetricPadding asymmetricPaddingInstance, string paddingSchemeName
where isUnapprovedPaddingScheme(asymmetricPaddingInstance, paddingSchemeName)
select asymmetricPaddingInstance, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingSchemeName