/**
 * @name Block cipher mode of operation
 * @description Identifies all potential block cipher modes of operations 
 *              across supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis framework
import python

// Import experimental cryptographic concepts for mode detection
import experimental.cryptography.Concepts

// Define cryptographic block mode source variable
from BlockMode cryptoMode

// Generate results: 
// - Crypto mode instance
// - Descriptive message with algorithm name
select cryptoMode, "Use of algorithm " + cryptoMode.getBlockModeName()