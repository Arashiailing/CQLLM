/**
 * @name Vulnerable asymmetric encryption padding detection
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically insecure or not explicitly verified as secure by recognized
 * cryptographic standards. This analysis flags potentially vulnerable padding configurations
 * by exclusively permitting the strongest padding techniques (OAEP, KEM, PSS) and marking
 * all alternative schemes as potential security vulnerabilities.
 * 
 * The analysis focuses on padding implementations that might be vulnerable
 * to cryptographic attacks when utilized in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Establish the set of cryptographically secure padding schemes for asymmetric encryption
// These specific padding techniques are the only ones considered secure
from AsymmetricPadding weakPaddingScheme, string algorithmIdentifier
where
  // Retrieve the padding algorithm identifier from the implementation details
  algorithmIdentifier = weakPaddingScheme.getPaddingName()
  // Exclude implementations that utilize approved secure padding methods
  and not algorithmIdentifier = ["OAEP", "KEM", "PSS"]
select weakPaddingScheme, "Identified unapproved, weak, or unknown asymmetric padding algorithm: " + algorithmIdentifier