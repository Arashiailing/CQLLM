/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding mechanisms that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. This analysis identifies potentially vulnerable padding configurations
 * by exclusively permitting the most robust padding methods (OAEP, KEM, PSS) and flagging
 * all other schemes as potential security risks.
 * 
 * The query specifically examines padding implementations that could be susceptible
 * to cryptographic attacks when utilized in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes for asymmetric encryption
// These specific padding techniques are considered secure for asymmetric encryption
from AsymmetricPadding paddingScheme, string algorithmIdentifier
where
  // Retrieve the padding algorithm identifier from the implementation
  algorithmIdentifier = paddingScheme.getPaddingName()
  // Exclude implementations that use secure padding methods
  and not algorithmIdentifier = ["OAEP", "KEM", "PSS"]
select paddingScheme, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + algorithmIdentifier