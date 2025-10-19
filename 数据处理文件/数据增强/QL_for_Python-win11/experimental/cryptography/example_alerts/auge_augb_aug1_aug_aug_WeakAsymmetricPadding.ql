/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This query identifies asymmetric encryption padding methods that are either
 * cryptographically weak or not explicitly recognized as secure according to
 * established security standards. The query specifically excludes known secure
 * padding techniques such as OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * Any padding method not in this approved list is flagged as a potential security risk.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define a list of padding schemes that are considered cryptographically secure
string securePaddingMethods() {
  result = ["OAEP", "KEM", "PSS"]
}

// Query to find asymmetric padding implementations that use unapproved schemes
from AsymmetricPadding paddingAlgorithm, string paddingType
where
  // Extract the padding scheme name from the implementation
  paddingType = paddingAlgorithm.getPaddingName()
  // Check if the padding scheme is not in the list of approved methods
  and paddingType != securePaddingMethods()
select paddingAlgorithm, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingType