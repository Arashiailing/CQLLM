import python

/**
 * CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * This query detects the storage of sensitive information in cleartext.
 */

class CleartextStorageQuery extends Query {
  /**
   * Find functions that store sensitive information in cleartext.
   */
  from Function f, DataFlow::Node source, DataFlow::Node sink
  where f.hasName("storeSensitiveInfo")
    and DataFlow::localFlow(source, sink)
    and source instanceof Expr
    and sink instanceof Expr
    and not sink.getType().hasName("SecureStorage")
  select f, "This function stores sensitive information in cleartext."
}