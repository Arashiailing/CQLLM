/**
 * @name Block cipher mode of operation detection
 * @description Identifies all instances of block cipher modes of operation in the codebase
 *              that utilize supported cryptographic libraries. This query helps in assessing
 *              the cryptographic practices and identifying potential security risks associated
 *              with specific block cipher modes.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python library for code analysis
import python

// Import experimental cryptography concepts for handling cryptographic operations
import experimental.cryptography.Concepts

// Select all block cipher mode instances from the BlockMode class
from BlockMode cipherMode

// Query statement: Select the cipher mode and return its name along with usage information
select cipherMode, "Use of algorithm " + cipherMode.getBlockModeName()