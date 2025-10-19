/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding mechanisms that are either
 * cryptographically insecure or not explicitly validated as secure by
 * recognized security standards. This analysis identifies potentially
 * vulnerable padding configurations by exclusively permitting the most
 * robust padding techniques (OAEP, KEM, PSS) and flagging all other
 * schemes as possible security threats.
 * 
 * The analysis specifically focuses on padding implementations that could
 * be susceptible to cryptographic attacks in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes for asymmetric encryption
// These padding methods have been extensively vetted and approved by security experts
from AsymmetricPadding paddingMethod, string paddingAlgorithm
where
  // Retrieve the name of the padding algorithm from the implementation
  paddingAlgorithm = paddingMethod.getPaddingName()
  // Verify that the padding method is not among the approved secure schemes
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithm