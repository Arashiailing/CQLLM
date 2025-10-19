/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. This analysis flags potentially vulnerable padding configurations
 * by allowing only the most secure padding methods (OAEP, KEM, PSS) and marking
 * all other schemes as potential security risks.
 * 
 * The analysis specifically targets padding implementations that may be vulnerable
 * to cryptographic attacks in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding schemes for asymmetric encryption
// Only these specific padding techniques are considered secure
from AsymmetricPadding paddingImpl, string paddingName
where
  // Extract the padding algorithm name from the implementation
  paddingName = paddingImpl.getPaddingName()
  // Check if the padding method is not in the list of secure schemes
  and not paddingName = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingName