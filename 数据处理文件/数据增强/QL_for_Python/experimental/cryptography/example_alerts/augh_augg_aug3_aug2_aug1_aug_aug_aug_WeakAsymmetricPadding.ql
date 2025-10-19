/**
 * @name Vulnerable asymmetric encryption padding
 * @description
 * This query detects padding schemes in asymmetric encryption that are
 * either cryptographically insecure or not recognized as secure by
 * established security standards. The analysis employs a whitelist-based
 * approach, exclusively accepting strong padding methods (OAEP, KEM, PSS)
 * while marking all other schemes as potential security risks.
 * 
 * The detection targets padding implementations that could be vulnerable
 * to cryptographic attacks when used in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify and flag insecure padding schemes for asymmetric encryption
from AsymmetricPadding insecurePadding, string paddingName
where
  // Extract the padding algorithm identifier from the implementation
  paddingName = insecurePadding.getPaddingName()
  // Exclude implementations that use cryptographically secure padding methods
  and not paddingName = ["OAEP", "KEM", "PSS"]
select insecurePadding, "Identified unapproved, weak, or unknown asymmetric padding algorithm: " + paddingName