/**
 * @name Alert suppression detection
 * @description Detects and examines alert suppression mechanisms within Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression functionality
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling capabilities
private import semmle.python.Comment as PythonComment

// Represents an individual Python comment line
class SingleLineComment instanceof PythonComment::Comment {
  // Determine if comment contains specific positioning data
  predicate hasLocationInfo(
    string path, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    // Confirm positioning matches parent class positioning details
    super.getLocation().hasLocationInfo(path, lineStart, colStart, lineEnd, colEnd)
  }

  // Retrieve the textual content of the comment
  string getText() { result = super.getContents() }

  // Obtain string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node equipped with position tracking
class AstNode instanceof PythonComment::AstNode {
  // Determine if node contains specific positioning data
  predicate hasLocationInfo(
    string path, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    // Confirm positioning matches parent class positioning details
    super.getLocation().hasLocationInfo(path, lineStart, colStart, lineEnd, colEnd)
  }

  // Obtain string representation of the node
  string toString() { result = super.toString() }
}

// Establish suppression connections between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression directive. Both pylint and pyflakes acknowledge this format, 
 * so lgtm should provide equivalent support.
 */
// Represents a suppression comment following noqa conventions
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor validates comment conforms to noqa pattern
  NoqaSuppressionComment() {
    // Identify case-insensitive noqa with optional trailing content
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code scope affected by this suppression
  override predicate covers(
    string path, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    // Extract comment positioning and verify it begins at column 1
    this.hasLocationInfo(path, lineStart, _, lineEnd, colEnd) and
    colStart = 1
  }
}