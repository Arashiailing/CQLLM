/**
 * @name Alert suppression
 * @description Detects and processes alert suppression mechanisms in Python code by analyzing comment patterns
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for implementing suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import Python comment analysis utilities for examining source code comments
private import semmle.python.Comment as PyComment

// AST nodes enhanced with precise location tracking capabilities
class LocatedAstNode instanceof PyComment::AstNode {
  // Generate string representation of the AST node
  string toString() { result = super.toString() }

  // Validate location coordinates correspond to the node's position
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }
}

// Single-line comments with detailed location tracking functionality
class LocatedSingleLineComment instanceof PyComment::Comment {
  // Generate string representation of the comment
  string toString() { result = super.toString() }

  // Retrieve the actual text content from the comment
  string getText() { result = super.getContents() }

  // Validate location coordinates correspond to the comment's position
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }
}

// Establish suppression relationship using the AlertSuppUtil template
import AlertSuppUtil::Make<LocatedAstNode, LocatedSingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Suppression comments that conform to the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof LocatedSingleLineComment {
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