/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding mechanisms that are either
 * cryptographically weak or not explicitly validated as secure by established
 * cryptographic standards. This analysis identifies potentially vulnerable padding
 * configurations by exclusively permitting the most secure padding methods
 * (OAEP, KEM, PSS) and flagging all other schemes as security concerns.
 * 
 * The query specifically targets padding implementations that could be
 * susceptible to cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Cryptographically secure padding schemes for asymmetric encryption
// These techniques are recognized as resistant to known cryptographic attacks
from AsymmetricPadding paddingImpl, string paddingScheme
where
  // Extract the padding algorithm identifier from the implementation
  paddingScheme = paddingImpl.getPaddingName()
  // Filter out implementations using approved secure padding methods
  and not paddingScheme in ["OAEP", "KEM", "PSS"]
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme