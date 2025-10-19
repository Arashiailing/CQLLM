/**
 * @name Detection of insecure asymmetric encryption padding
 * @description
 * This query identifies asymmetric encryption padding methods that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * cryptographic standards. The analysis specifically flags padding implementations
 * that are not among the most secure padding schemes (OAEP, KEM, PSS), treating
 * them as potential security vulnerabilities.
 * 
 * Such insecure padding configurations may expose cryptographic systems to various
 * attacks when utilized in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define approved secure padding schemes for asymmetric encryption
from AsymmetricPadding asymmetricPadding, string algorithmName
where
  // Retrieve the name of the padding algorithm being used
  algorithmName = asymmetricPadding.getPaddingName()
  // Identify padding implementations that do not use secure methods
  and not algorithmName = ["OAEP", "KEM", "PSS"]
select asymmetricPadding, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + algorithmName