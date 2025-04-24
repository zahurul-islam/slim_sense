class SuggestedQuestions {
  static const List<String> weightLoss = [
    "What's a healthy rate of weight loss per week?",
    "How can I reduce belly fat specifically?",
    "What are the best exercises for weight loss?",
    "How should I adjust my diet for weight loss?",
    "Why am I not losing weight despite diet and exercise?",
    "How many calories should I eat to lose weight?",
    "What's more important for weight loss: diet or exercise?",
    "How can I overcome a weight loss plateau?",
  ];
  
  static const List<String> nutrition = [
    "What should a balanced meal look like?",
    "How much protein do I need daily?",
    "Are carbs really bad for you?",
    "What are the healthiest snacks for energy?",
    "How can I reduce sugar cravings?",
    "What foods help reduce inflammation?",
    "How much water should I drink daily?",
    "What's the difference between good and bad fats?",
  ];
  
  static const List<String> fitness = [
    "How often should I work out each week?",
    "What's the best way to build muscle?",
    "How can I improve my cardio endurance?",
    "What exercises are best for beginners?",
    "How long should my workout sessions be?",
    "What's the best time of day to exercise?",
    "How can I stay motivated to exercise regularly?",
    "What should I eat before and after workouts?",
  ];
  
  static const List<String> wellness = [
    "How can I improve my sleep quality?",
    "What are some effective stress management techniques?",
    "How does stress affect weight and health?",
    "What are the benefits of meditation?",
    "How can I establish a healthy morning routine?",
    "What are some good habits for overall wellbeing?",
    "How can I improve my mental health through lifestyle changes?",
    "What's the connection between gut health and overall health?",
  ];
  
  static List<String> getRandomQuestions(int count) {
    final allQuestions = [
      ...weightLoss,
      ...nutrition,
      ...fitness,
      ...wellness,
    ];
    
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }
}
