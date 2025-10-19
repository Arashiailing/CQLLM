/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This analysis identifies padding mechanisms used in asymmetric encryption that are
 * either cryptographically weak or not recognized as secure by established security
 * standards. The query operates on a whitelist approach, exclusively permitting
 * robust padding methods (OAEP, KEM, PSS) while flagging all other schemes as
 * potential security vulnerabilities.
 * 
 * The detection focuses on padding implementations that may be susceptible to
 * cryptographic attacks when deployed in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify and flag insecure padding schemes for asymmetric encryption
from AsymmetricPadding weakPaddingScheme, string paddingAlgorithm
where
  // Extract the padding algorithm identifier from the implementation
  paddingAlgorithm = weakPaddingScheme.getPaddingName()
  // Filter out any implementations that use cryptographically secure padding methods
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select weakPaddingScheme, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithm