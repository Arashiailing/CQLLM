/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either cryptographically weak
 * or not explicitly approved by security standards. This analysis targets padding 
 * implementations that deviate from industry best practices, excluding well-established 
 * secure methods such as OAEP (Optimal Asymmetric Encryption Padding), KEM (Key 
 * Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * 
 * Any padding scheme not in the approved list is flagged as a potential security 
 * vulnerability, which could lead to cryptographic weaknesses including chosen 
 * ciphertext attacks, padding oracle attacks, or insufficient randomness in 
 * encryption processes.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Predicate that returns all cryptographically approved padding schemes
string getCryptographicallyApprovedScheme() {
  result = ["OAEP", "KEM", "PSS"]
}

// Query to identify implementations using unapproved padding schemes
from AsymmetricPadding paddingImpl, string schemeIdentifier
where
  // Extract the padding scheme name from the implementation
  schemeIdentifier = paddingImpl.getPaddingName()
  // Exclude all approved padding schemes from detection
  and schemeIdentifier != getCryptographicallyApprovedScheme()
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + schemeIdentifier