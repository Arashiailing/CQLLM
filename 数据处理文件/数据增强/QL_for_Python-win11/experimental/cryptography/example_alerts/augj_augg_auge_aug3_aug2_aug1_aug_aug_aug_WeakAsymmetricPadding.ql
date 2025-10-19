/**
 * @name Vulnerable asymmetric encryption padding
 * @description
 * Identifies padding schemes used in asymmetric encryption that are either
 * cryptographically weak or lack explicit validation from established
 * security standards. This query flags potentially insecure padding
 * configurations by exclusively allowing the most robust padding methods
 * (OAEP, KEM, PSS) and treating all other schemes as potential security risks.
 * 
 * The analysis specifically targets padding implementations that may be
 * vulnerable to cryptographic attacks in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the collection of cryptographically validated padding methods for asymmetric encryption
// These padding techniques have undergone thorough security evaluation and are recommended by experts
from AsymmetricPadding paddingImpl, string algorithmName
where
  // Extract the algorithm name from the padding implementation
  algorithmName = paddingImpl.getPaddingName()
  // Check if the padding method is not in the list of approved secure schemes
  and not algorithmName.matches(["OAEP", "KEM", "PSS"])
select paddingImpl, "Found potentially weak or unverified asymmetric padding algorithm: " + algorithmName