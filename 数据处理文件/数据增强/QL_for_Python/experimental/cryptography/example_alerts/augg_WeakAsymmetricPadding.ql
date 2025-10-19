/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies cryptographic implementations using asymmetric padding schemes
 * that are either weak, unapproved, or not recognized as secure. Approved
 * secure padding schemes include OAEP, KEM, and PSS. Other schemes may
 * introduce vulnerabilities in cryptographic operations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding schemes as constant list
string securePaddingScheme() { result = ["OAEP", "KEM", "PSS"] }

// Identify asymmetric padding implementations
from AsymmetricPadding paddingImplementation
where
  // Extract padding scheme name from implementation
  exists(string paddingName |
    paddingName = paddingImplementation.getPaddingName() and
    // Verify scheme is not in approved secure list
    not paddingName = securePaddingScheme()
  )
select paddingImplementation, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingImplementation.getPaddingName()