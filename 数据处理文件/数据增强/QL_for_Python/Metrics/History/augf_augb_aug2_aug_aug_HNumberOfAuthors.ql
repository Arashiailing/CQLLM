/**
 * @name Number of authors
 * @description Quantifies the diversity of contributors per Python file by tracking unique 
 *              individuals who have made modifications. This metric serves as an indicator 
 *              for collaborative engagement levels and potential single points of failure 
 *              in code ownership across the project's file ecosystem.
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

// Define the scope of analysis targeting Python modules with actual code content
from Module targetModule
// Apply filter constraint to ensure only modules with measurable code are considered
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
// Compute and present the unique author count for each qualifying Python module
select targetModule, 
       count(Author fileAuthor | fileAuthor.getAnEditedFile() = targetModule.getFile())