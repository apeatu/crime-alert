class AutoCompleteItem {
  /// The id of the place. This helps to fetch the lat,lng of the place.
  late String id;

  /// The text (name of place) displayed in the autocomplete suggestions list.
  late String text;

  /// Assistive index to begin highlight of matched part of the [text] with
  /// the original query
  late int offset;

  /// Length of matched part of the [text]
  late int length;

  @override
  String toString() {
    return 'AutoCompleteItem{id: $id, text: $text, offset: $offset, length: $length}';
  }
}