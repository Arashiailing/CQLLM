import python

/**
 * CWE-22: Path Injection
 * This query detects instances where user-controlled data is used in a file path.
 */

from PathAccess pa, DataFlow::Source source, DataFlow::Sink sink
where pa.getPath() = sink.getExpr() and source.asExpr() = pa.getPath()
select pa, "This path access is influenced by user-controlled data, which can lead to path injection."