/**
 * @name Source File Type Classification
 * @description Identifies and classifies code files by detecting auto-generated
 *              artifacts and test components using pattern recognition and
 *              structural context analysis. This classification enables
 *              security analysts to filter and prioritize code review efforts
 *              based on file origin and purpose.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import core Python analysis framework for language-specific processing
import python
// Import auto-generated code detection utilities for identifying machine-created files
import semmle.python.filters.GeneratedCode
// Import test identification module for locating test-related code components
import semmle.python.filters.Tests

// Core classification logic that determines file type based on generation source and functional context
from File sourceFile, string classificationType
where 
  // Classification condition 1: Files automatically produced by code generation tools or processes
  (sourceFile instanceof GeneratedFile and classificationType = "generated")
  // Classification condition 2: Files located within test directories or serving test functions
  or
  (exists(TestScope testScope | testScope.getLocation().getFile() = sourceFile) and classificationType = "test")
select sourceFile, classificationType