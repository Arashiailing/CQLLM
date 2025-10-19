/**
 * @name Block cipher mode detection
 * @description Identifies all potential block cipher modes of operations implemented through supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language modules and Semmle's cryptographic concepts
import python
import semmle.python.Concepts

// Identify cryptographic operations and their corresponding block modes
from Cryptography::CryptographicOperation cryptoOp, string modeName
where modeName = cryptoOp.getBlockMode() // Extract block mode from cryptographic operation
select cryptoOp, "Detected algorithm using mode: " + modeName // Output operation and algorithm mode description