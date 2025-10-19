/**
 * @description Identifies and enumerates all callable functions within a Python codebase.
 *              This query serves as a foundational metric for understanding the scope
 *              and distribution of functions across the analyzed project.
 * @kind metrics
 * @id py/callable-extents
 * @metricType function
 */

// Import the core Python analysis library to access fundamental code elements
// and their properties for comprehensive code examination
import python

// Define the analysis scope to include all Python callable functions,
// which represent executable code blocks that can be invoked
from Function pythonFunction

// Output the source location and the function object for each identified callable.
// This provides both positional context and the actual function reference
// for further analysis or visualization purposes
select pythonFunction.getLocation(), pythonFunction