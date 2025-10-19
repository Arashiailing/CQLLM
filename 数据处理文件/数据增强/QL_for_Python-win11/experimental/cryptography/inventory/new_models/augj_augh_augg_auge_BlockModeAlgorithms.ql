/**
 * @name Block cipher mode of operation
 * @description Identifies all instances of block cipher modes used in supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

/* Import necessary Python language support for code analysis */
import python

/* Import experimental cryptography concepts for cryptographic operation analysis */
import experimental.cryptography.Concepts

/* Define source of block cipher modes and prepare reporting */
from BlockMode blockCipherMode

/* Generate alert for each detected block cipher mode with algorithm name */
select blockCipherMode, "Use of algorithm " + blockCipherMode.getBlockModeName()