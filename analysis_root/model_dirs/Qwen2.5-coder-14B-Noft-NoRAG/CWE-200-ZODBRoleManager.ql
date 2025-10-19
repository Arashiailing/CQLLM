import python

/**
 * Query to detect CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * This query searches for instances where sensitive information is stored in cleartext.
 */

from DataFlow::Node source, DataFlow::Node sink
where
  // Define the source of sensitive information
  source instanceof SensitiveData and
  // Define the sink where the data is stored
  sink instanceof Storage and
  // Ensure there is a data flow from source to sink
  DataFlow::flowsTo(source, sink)
select sink, "Sensitive information is stored in cleartext at this location."