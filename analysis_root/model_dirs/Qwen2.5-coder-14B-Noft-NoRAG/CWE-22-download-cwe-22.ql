import python

/**
 * CWE-22: Path Injection
 * This query detects instances where user-controlled data is used in a file path.
 */

from File f, DataFlow::Node source, DataFlow::Node sink
where
  // Find a source of user-controlled data
  source instanceof UserInput and
  // Find a sink that is a file path
  sink instanceof File and
  // Check if there is a data flow from the source to the sink
  DataFlow::flowsTo(source, sink)
select sink, "This file path is influenced by user input, which may lead to path injection."