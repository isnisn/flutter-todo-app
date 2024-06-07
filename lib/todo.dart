/// Todo class to store todo title and description
/// It can be used to store more data like date, priority etc.
class Todo {
  final String _title;
  final String _description;

  Todo({required title, required description})
      : _title = title,
        _description = description;

  String getTitle() {
    return _title;
  }

  String getDescription() {
    return _description;
  }
}
