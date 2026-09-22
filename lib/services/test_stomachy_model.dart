import 'stomachy_model_service.dart';

Future<void> testStomachyModel() async {
  final model = StomachyModelService();

  await model.loadModel();

  final probability = model.predict(
    age: 40,
    gender: 'Female',
    heartBurn: 'Once a month',
    hbFrequency: 'Monthly',
    reflux: 'No',
    refluxFrequency: 'No symptoms',
    chestPain: 'No',
    cpFrequency: 'No symptoms',
    abdFullness: 'No',
    medication: 'No',
    enoughSleep: 'no',
  );

  final result = model.classify(probability);

  print('==============================');
  print('STOMACHY MODEL TEST');
  print('Probability GORD+: $probability');
  print('Result: $result');
  print('==============================');

  model.dispose();
}