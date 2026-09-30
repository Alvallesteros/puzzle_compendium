// Reads Clock once and Returns it as a Seed
int currentSeed() {
  return DateTime.now().millisecondsSinceEpoch;
}