#include <cstddef>
#include <iostream>
#include <random>
#include <vector>

/*
 * @brief Randomly pick a number between lowerLimit and uperLimit inclusive.
 * @param n The upper limit (exclusive) for the random number generation
 * @return A random number between lowerLimit and upperLimit inclusive.
 */
using std::string;

size_t randomPick(const size_t lowerLimit, const size_t upperLimit) {
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_int_distribution<size_t> dis(lowerLimit, upperLimit);
  return dis(gen);
}

int main(int argc, char** argv) {
  std::vector<std::string> args(argv, argv + argc);
  const size_t rollStart{1};
  const size_t rollEnd{args.size() - 1};
  const size_t rollResult{randomPick(rollStart, rollEnd)};

  std::cout << args.at(rollResult) << std::endl;
  return 0;
}
