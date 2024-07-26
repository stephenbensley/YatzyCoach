# Yatzy Coach

Yatzy Coach is an iOS app that lets you play a solo game of [Yatzy](https://en.wikipedia.org/wiki/Yahtzee) and provides feedback on your moves. The repo has the following top-level directories:
- Coach implements the iOS app. For more information about the app, see the [app store listing](https://apps.apple.com/us/app/yatzycoach/id6575389687/).
- Resources contains the precomputed solution file and the content for the About and Help pages.
- Screenshots contains the various screenshots for the app store listing.
- Solver implements a MacOS app that solves the game of Yatzy offline and saves the results to a file.
- Tests implements the unit tests for the core game logic.
- Yatzy contains the core Yatzy logic shared between Coach and Solver.
