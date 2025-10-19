/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either cryptographically weak
 * or not explicitly recognized by established security standards. This analysis targets
 * padding implementations that deviate from industry best practices, specifically
 * excluding well-vetted secure methods such as OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * 
 * The analysis flags any padding scheme not present in the approved list as a potential
 * security vulnerability. Such deviations may lead to cryptographic weaknesses including
 * chosen ciphertext attacks, padding oracle attacks, or insufficient randomness in
 * encryption processes.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Predicate that returns all cryptographically secure padding schemes
string getSecurePaddingSchemes() {
  result = ["OAEP", "KEM", "PSS"]
}

// Query to detect implementations using unapproved padding schemes
from AsymmetricPadding asymmetricPadding, string paddingSchemeName
where
  // Extract the padding scheme identifier from the implementation
  paddingSchemeName = asymmetricPadding.getPaddingName()
  // Check if the padding scheme is not among the approved secure schemes
  and not paddingSchemeName = getSecurePaddingSchemes()
select asymmetricPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingSchemeName