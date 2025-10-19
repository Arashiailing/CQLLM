/**
 * @name Number of authors
 * @description Quantifies unique contributors per Python file to identify collaboration hotspots
 *              and knowledge silos. High values indicate intense collaboration or potential
 *              single points of failure.
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python language analysis module for code structure parsing
import python
// Import version control system module for file history and contributor data
import external.VCS

// Identify Python modules with measurable code content
from Module pyModule 
where exists(pyModule.getMetrics().getNumberOfLinesOfCode())
// Compute distinct contributor count per module
select pyModule, 
       count(Author author | author.getAnEditedFile() = pyModule.getFile())