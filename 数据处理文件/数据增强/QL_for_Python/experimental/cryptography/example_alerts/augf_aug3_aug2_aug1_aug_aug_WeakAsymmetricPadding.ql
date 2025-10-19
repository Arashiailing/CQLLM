/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding mechanisms that are either cryptographically 
 * insecure or not explicitly recognized by established security standards. This analysis 
 * flags padding implementations that deviate from industry best practices, 
 * specifically excluding well-vetted secure methods like OAEP (Optimal Asymmetric 
 * Encryption Padding), KEM (Key Encapsulation Mechanism), and PSS (Probabilistic 
 * Signature Scheme).
 * 
 * Padding schemes outside the approved list are flagged as potential security
 * vulnerabilities, which could lead to cryptographic weaknesses including chosen ciphertext
 * attacks, padding oracle attacks, or insufficient randomness in encryption operations.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define cryptographically secure and approved padding schemes
string getSecurePaddingMethods() {
  result = ["OAEP", "KEM", "PSS"]
}

// Identify padding implementations using unapproved schemes
from AsymmetricPadding paddingImpl, string schemeName
where 
  schemeName = paddingImpl.getPaddingName()
  and not exists(string secureMethod | 
    secureMethod = getSecurePaddingMethods() 
    and secureMethod = schemeName
  )
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + schemeName