List<T> reorderItems<T>(List<T> items, int oldIndex, int newIndex) {
  if (oldIndex < 0 || oldIndex >= items.length) {
    throw RangeError.index(oldIndex, items, 'oldIndex');
  }
  if (newIndex < 0 || newIndex > items.length) {
    throw RangeError.range(newIndex, 0, items.length, 'newIndex');
  }

  final reordered = List<T>.of(items);
  var targetIndex = newIndex;
  if (oldIndex < targetIndex) {
    targetIndex -= 1;
  }

  final item = reordered.removeAt(oldIndex);
  reordered.insert(targetIndex, item);
  return reordered;
}
