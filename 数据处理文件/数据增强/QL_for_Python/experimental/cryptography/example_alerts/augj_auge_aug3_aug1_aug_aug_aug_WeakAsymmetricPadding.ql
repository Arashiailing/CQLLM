/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding techniques that are either
 * cryptographically insecure or not explicitly validated as secure by
 * recognized cryptographic standards. This analysis flags padding configurations
 * that might create security vulnerabilities by exclusively permitting the most
 * robust padding methods (OAEP, KEM, PSS) and marking all others as potential
 * security threats.
 * 
 * The analysis specifically focuses on padding implementations that could be
 * vulnerable to cryptographic attacks in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// List of cryptographically secure padding schemes for asymmetric operations
// These are the only padding methods considered safe for asymmetric cryptographic operations
from AsymmetricPadding paddingMethod, string paddingName
where
  // Retrieve the padding scheme identifier from the implementation
  paddingName = paddingMethod.getPaddingName()
  // Exclude padding schemes that are in the approved secure methods list
  and not paddingName = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingName