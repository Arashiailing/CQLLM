/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects cryptographic operations that utilize asymmetric encryption padding schemes
 * which are considered insecure, deprecated, or not explicitly approved. The only
 * padding schemes recognized as secure for asymmetric cryptography are OAEP (Optimal
 * Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism), and PSS
 * (Probabilistic Signature Scheme). Implementation of other padding methods may
 * lead to cryptographic weaknesses and potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the list of approved secure padding schemes for asymmetric cryptography
string approvedSecurePaddingSchemes() { result = ["OAEP", "KEM", "PSS"] }

// Find all asymmetric padding implementations that use non-approved schemes
from AsymmetricPadding asymmetricPaddingImpl
where
  // Get the name of the padding scheme being used
  exists(string paddingSchemeName |
    paddingSchemeName = asymmetricPaddingImpl.getPaddingName() and
    // Check if the padding scheme is not in the approved secure list
    not paddingSchemeName = approvedSecurePaddingSchemes()
  )
select asymmetricPaddingImpl, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + asymmetricPaddingImpl.getPaddingName()