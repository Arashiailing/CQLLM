/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * cryptographic standards. This analysis flags padding configurations that may
 * introduce security vulnerabilities by permitting only the strongest padding
 * methods (OAEP, KEM, PSS) and marking all others as potential risks.
 * 
 * The query specifically focuses on padding implementations that could be
 * vulnerable to cryptographic attacks in asymmetric encryption contexts.
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
from AsymmetricPadding paddingMethod, string schemeName
where
  // Obtain the name of the padding algorithm from the implementation
  schemeName = paddingMethod.getPaddingName()
  // Exclude implementations that use secure padding methods
  and not schemeName = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + schemeName