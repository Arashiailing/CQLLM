/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code,
 * specifically handling 'noqa' comments used by pylint and pyflakes.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import utilities for handling alert suppression logic
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing for AST nodes and comments
private import semmle.python.Comment as P

// Represents AST nodes that provide location tracking capabilities
class AstNode instanceof P::AstNode {
  // Provides location details for the AST node
  predicate hasLocationInfo(
    string file, int start, int startColumn, int end, int endColumn
  ) {
    super.getLocation().hasLocationInfo(file, start, startColumn, end, endColumn)
  }

  // Returns string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments that provide location tracking
class SingleLineComment instanceof P::Comment {
  // Provides location details for the comment
  predicate hasLocationInfo(
    string file, int start, int startColumn, int end, int endColumn
  ) {
    super.getLocation().hasLocationInfo(file, start, startColumn, end, endColumn)
  }

  // Retrieves the text content of the comment
  string getText() { result = super.getContents() }

  // Returns string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a 'noqa' suppression comment that is recognized by both pylint and pyflakes.
 * This suppression mechanism should also be respected by LGTM.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Identifies comments that contain 'noqa' (case-insensitive) and may have additional content after it
  NoqaSuppressionComment() {
    this.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Returns the annotation identifier used for suppression
  override string getAnnotation() { result = "lgtm" }

  // Specifies the code coverage scope of this suppression comment, which covers entire lines starting from column 1
  override predicate covers(
    string file, int start, int startColumn, int end, int endColumn
  ) {
    // The suppression applies to entire lines starting from column 1
    this.hasLocationInfo(file, start, _, end, endColumn) and
    startColumn = 1
  }
}