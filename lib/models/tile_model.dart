// Author: Ilia Markelov (xmarke00)

class TileModel {
  bool _visible;
  bool _hasMine;
  bool _hasFlag;
  int _value;
  List<int> _offset;
  List<bool> _ltrb;

  TileModel(int row, int col)
      : _visible = false,
        _hasMine = false,
        _hasFlag = false,
        _value = 0,
        _offset = [row, col],
        _ltrb = [false, false, false, false];

  bool get visible => _visible;
  bool get hasMine => _hasMine;
  bool get hasFlag => _hasFlag;
  int get value => _value;
  int get row => _offset[0];
  int get col => _offset[1];
  List<bool> get ltrb => _ltrb;

  set setVisible(bool value) {
    _visible = value;
  }

  set setMine(bool value) {
    _hasMine = value;
  }

  set setFlag(bool value) {
    _hasFlag = value;
  }

  set setValue(int value) {
    _value = value;
  }

  set setOffset(List<int> value) {
    _offset = value;
  }

  set addBorder(int index) {
    _ltrb[index] = true;
  }
}