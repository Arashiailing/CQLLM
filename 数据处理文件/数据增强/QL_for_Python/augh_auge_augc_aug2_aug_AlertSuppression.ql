/**
 * @name Alert suppression
 * @description Provides detailed analysis of alert suppression mechanisms in Python code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for managing suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import Python comment processing utilities for comment analysis
private import semmle.python.Comment as PyComment

// Defines AST nodes with precise location tracking capabilities
class TrackedAstNode instanceof PyComment::AstNode {
  // Validate if node matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Generate textual representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with detailed location tracking
class TrackedSingleLineComment instanceof PyComment::Comment {
  // Determine if comment matches provided location coordinates
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Extract the textual content from the comment
  string getText() { result = super.getContents() }

  // Generate textual representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationship using AlertSuppUtil template
import AlertSuppUtil::Make<TrackedAstNode, TrackedSingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Identifies suppression comments following the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof TrackedSingleLineComment {
  // Constructor that recognizes noqa comment patterns
  NoqaSuppressionComment() {
    this.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provide the identifier for this suppression annotation
  override string getAnnotation() { result = "lgtm" }

  // Define the coverage scope for this suppression annotation
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Verify comment location alignment and enforce line-start positioning
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}