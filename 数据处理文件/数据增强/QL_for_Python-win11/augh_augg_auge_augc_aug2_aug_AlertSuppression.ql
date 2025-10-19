/**
 * @name Alert suppression
 * @description Analyzes alert suppression mechanisms in Python code through comment processing
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for handling suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtils
// Import Python comment processing utilities for analyzing code comments
private import semmle.python.Comment as PythonComment

// Represents AST nodes with precise location tracking capabilities
class LocationTrackedAstNode instanceof PythonComment::AstNode {
  // Generate textual representation of the AST node
  string toString() { result = super.toString() }

  // Verify location coordinates match the node's position
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }
}

// Represents single-line comments with detailed location tracking
class LocationTrackedSingleLineComment instanceof PythonComment::Comment {
  // Generate textual representation of the comment
  string toString() { result = super.toString() }

  // Extract the actual text content from the comment
  string getText() { result = super.getContents() }

  // Verify location coordinates match the comment's position
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }
}

// Implement suppression relationship creation using the AlertSuppressionUtils template
import AlertSuppressionUtils::Make<LocationTrackedAstNode, LocationTrackedSingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents suppression comments following the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof LocationTrackedSingleLineComment {
  // Constructor that identifies noqa comment patterns
  NoqaSuppressionComment() {
    this.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provide the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the coverage scope for this suppression annotation
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Validate comment location and enforce line-start positioning
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}