/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This analysis identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * cryptographic standards. The query aims to detect padding configurations that
 * could introduce security vulnerabilities by only allowing the strongest padding
 * methods (OAEP, KEM, PSS) and marking all others as potential risks.
 * 
 * The focus is specifically on padding implementations that might be susceptible
 * to cryptographic attacks in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes
// These padding methods are considered safe for asymmetric cryptographic operations
from AsymmetricPadding algoPadding, string paddingScheme
where
  // Obtain the name of the padding algorithm from the implementation
  paddingScheme = algoPadding.getPaddingName()
  // Exclude implementations that use secure padding methods
  and not paddingScheme = ["OAEP", "KEM", "PSS"]
select algoPadding, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingScheme