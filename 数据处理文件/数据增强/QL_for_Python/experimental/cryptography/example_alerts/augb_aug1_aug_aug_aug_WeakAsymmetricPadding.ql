/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically weak or not explicitly validated as secure by established
 * cryptographic standards. This analysis flags potentially vulnerable padding
 * configurations by exclusively permitting the most secure padding methods
 * (OAEP, KEM, PSS) and marking all other schemes as security concerns.
 * 
 * The query specifically focuses on padding implementations that could be
 * vulnerable to cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// List of cryptographically secure padding schemes for asymmetric encryption
// These padding techniques are recognized as resistant to known cryptographic attacks
from AsymmetricPadding cryptoPadding, string schemeName
where
  // Retrieve the padding algorithm identifier from the implementation
  schemeName = cryptoPadding.getPaddingName()
  // Exclude implementations that use approved secure padding methods
  and not schemeName in ["OAEP", "KEM", "PSS"]
select cryptoPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + schemeName