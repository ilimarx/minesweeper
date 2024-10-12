class HomepageModel {
  String selectedDifficulty = 'Medium'; // Default difficulty
  List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  void setDifficulty(String difficulty) {
    selectedDifficulty = difficulty;
  }
}