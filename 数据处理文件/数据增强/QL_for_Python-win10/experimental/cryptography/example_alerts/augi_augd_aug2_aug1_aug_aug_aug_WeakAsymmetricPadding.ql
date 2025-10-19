/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding implementations that utilize
 * cryptographic padding schemes not recognized as secure by current
 * cryptographic standards. This analysis flags potentially vulnerable
 * padding configurations by exclusively permitting industry-standard
 * secure padding methods (OAEP, KEM, PSS) and marking all other
 * implementations as potential security risks.
 * 
 * The analysis focuses on padding schemes that could be vulnerable to
 * cryptographic attacks in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// List of secure padding schemes for asymmetric cryptographic operations
// These methods are widely accepted as secure in current cryptographic standards
from AsymmetricPadding asymmetricPaddingImpl, string paddingAlgorithm
where
  // Extract the padding algorithm identifier from the implementation
  paddingAlgorithm = asymmetricPaddingImpl.getPaddingName()
  // Filter out implementations that use approved secure padding methods
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select asymmetricPaddingImpl, "Identified potentially insecure asymmetric padding algorithm: " + paddingAlgorithm