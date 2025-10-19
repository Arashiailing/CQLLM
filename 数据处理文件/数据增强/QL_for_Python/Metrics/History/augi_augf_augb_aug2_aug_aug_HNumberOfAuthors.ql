/**
 * @name Number of authors
 * @description Measures contributor diversity for each Python file by counting distinct 
 *              individuals who have modified the file. This metric helps identify files 
 *              with high collaboration levels versus potential knowledge silos or 
 *              single points of failure in the codebase.
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python language analysis capabilities for syntactic and semantic code examination
import python
// Integrate version control system functionality to access historical contributor data
import external.VCS

// Define the main query targeting Python modules containing actual code
from Module pythonModule
// Filter to include only modules with measurable code content (non-empty files)
where exists(pythonModule.getMetrics().getNumberOfLinesOfCode())
// Calculate and return the count of unique authors for each qualifying Python module
select pythonModule, 
       count(Author moduleAuthor | moduleAuthor.getAnEditedFile() = pythonModule.getFile())