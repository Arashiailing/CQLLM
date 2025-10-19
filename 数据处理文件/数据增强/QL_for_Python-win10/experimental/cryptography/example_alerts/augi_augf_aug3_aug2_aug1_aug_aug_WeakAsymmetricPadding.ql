/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either cryptographically 
 * weak or not recognized by established security standards. This analysis targets 
 * padding implementations that do not conform to industry best practices, 
 * specifically excluding proven secure methods such as OAEP (Optimal Asymmetric 
 * Encryption Padding), KEM (Key Encapsulation Mechanism), and PSS (Probabilistic 
 * Signature Scheme).
 * 
 * Any padding scheme not present in the approved list is flagged as a potential
 * security vulnerability, which may result in cryptographic weaknesses including 
 * chosen ciphertext attacks, padding oracle attacks, or inadequate randomness 
 * in encryption operations.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define a collection of cryptographically secure and approved padding schemes
string getApprovedPaddingSchemes() {
  result = ["OAEP", "KEM", "PSS"]
}

// Check if a given padding scheme is considered secure
predicate isSecurePaddingScheme(string paddingScheme) {
  exists(string approvedScheme | 
    approvedScheme = getApprovedPaddingSchemes() 
    and approvedScheme = paddingScheme
  )
}

// Find asymmetric padding implementations that use non-approved schemes
from AsymmetricPadding paddingInstance, string paddingType
where 
  paddingType = paddingInstance.getPaddingName()
  and not isSecurePaddingScheme(paddingType)
select paddingInstance, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingType