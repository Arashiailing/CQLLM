/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding implementations that utilize
 * cryptographic padding schemes not recognized as secure by current
 * cryptographic standards. This analysis identifies potentially vulnerable
 * padding configurations by strictly allowing only industry-standard
 * secure padding methods (OAEP, KEM, PSS) and flagging all other
 * implementations as potential security vulnerabilities.
 * 
 * The analysis targets padding schemes that may be susceptible to
 * cryptographic attacks in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding schemes for asymmetric cryptographic operations
// These padding methods are widely accepted as secure in cryptographic standards
from AsymmetricPadding asymmetricPadding, string paddingScheme
where
  // Extract the padding algorithm identifier from the implementation
  paddingScheme = asymmetricPadding.getPaddingName()
  // Identify implementations that do not use cryptographically secure padding
  and not paddingScheme = ["OAEP", "KEM", "PSS"]
select asymmetricPadding, "Identified potentially insecure asymmetric padding algorithm: " + paddingScheme