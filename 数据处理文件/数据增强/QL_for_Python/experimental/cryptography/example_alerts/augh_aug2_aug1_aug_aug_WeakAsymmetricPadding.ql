/**
 * @name Insecure or non-standard asymmetric encryption padding
 * @description
 * Identifies asymmetric encryption padding techniques that are either cryptographically
 * insecure or not explicitly recognized as secure by cryptographic standards. This analysis
 * focuses on padding implementations that do not conform to industry best practices,
 * excluding well-vetted secure methods such as OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * 
 * Any padding scheme absent from the approved list is flagged as a potential security
 * risk, which may result in cryptographic vulnerabilities including chosen ciphertext
 * attacks, padding oracle attacks, or inadequate entropy in encryption operations.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Function that returns all secure and approved padding schemes
string getSecurePaddingSchemes() {
  result = ["OAEP", "KEM", "PSS"]
}

// Query to find padding implementations using non-approved schemes
from AsymmetricPadding paddingAlgorithm, string paddingScheme
where
  // Retrieve the padding scheme name from the algorithm implementation
  paddingScheme = paddingAlgorithm.getPaddingName()
  // Filter out all approved padding schemes from the results
  and paddingScheme != getSecurePaddingSchemes()
select paddingAlgorithm, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingScheme