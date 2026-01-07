// lib/screens/timer_screen.dart (FINAL CODE with Animated Quotes, Circular Timer, and Goal Setter)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/focus_timer_state_model.dart';

// -----------------------------------------------------------------
// HELPER METHOD: Goal Setter Dialog
// -----------------------------------------------------------------

Future<void> _showGoalSetterDialog(
  BuildContext context,
  FocusTimerStateModel timerModel,
) async {
  final TextEditingController controller = TextEditingController(
    text: timerModel.currentGoal != 'No task currently linked.'
        ? timerModel.currentGoal
        : '',
  );

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Set Your Focus Goal'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('What are you focusing on this session?'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Task or Goal (e.g., Finish Chapter 5)',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Set Goal'),
            onPressed: () {
              // Update the model and dismiss the dialog
              timerModel.setGoal(controller.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// -----------------------------------------------------------------
// 1. WIDGET: Custom Painter for the Circular Progress Arc (FIXED)
// -----------------------------------------------------------------

class _ProgressCirclePainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color progressColor;
  final double strokeWidth; // Final variable

  _ProgressCirclePainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
    this.strokeWidth =
        15.0, // FIX: Initialized the final variable with a default value
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth; // Uses the now initialized strokeWidth

    canvas.drawCircle(center, radius, basePaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double remainingRatio = 1.0 - progress;
    double sweepAngle = 2 * 3.1415926535 * remainingRatio;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// -----------------------------------------------------------------
// 2. WIDGET: Combined Digital and Circle Timer Display
// -----------------------------------------------------------------

class _ProgressCircleTimer extends StatelessWidget {
  final Duration remainingDuration;
  final Duration totalPhaseDuration;
  final String formattedTime;
  final Color primaryColor;

  const _ProgressCircleTimer({
    required this.remainingDuration,
    required this.totalPhaseDuration,
    required this.formattedTime,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeconds = totalPhaseDuration.inSeconds;
    final remainingSeconds = remainingDuration.inSeconds;

    final elapsedSeconds = totalSeconds - remainingSeconds;
    double progress = totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;
    progress = progress.clamp(0.0, 1.0);

    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. CustomPainter draws the circle and arc
            CustomPaint(
              size: const Size.square(250),
              // The constructor call here is now valid
              painter: _ProgressCirclePainter(
                progress: progress,
                baseColor: primaryColor.withOpacity(0.2),
                progressColor: primaryColor,
              ),
            ),
            // 2. Digital time text in the center
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w100,
                color: primaryColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. WIDGET: _QuoteCycler (Animated Quotes)
// -------------------------------------------------------------
class _QuoteCycler extends StatefulWidget {
  final Color primaryColor;
  const _QuoteCycler({required this.primaryColor});

  @override
  State<_QuoteCycler> createState() => _QuoteCyclerState();
}

class _QuoteCyclerState extends State<_QuoteCycler> {
  int _currentQuoteIndex = 0;
  Timer? _timer;

  // At least 10 Motivational Quotes
  final List<String> _quotes = const [
    "The way to get started is to quit talking and begin doing. - Walt Disney",
    "Productivity is never an accident. It is always the result of a commitment to excellence.",
    "Do the hardest thing first. You can always celebrate later.",
    "Procrastination is the thief of time.",
    "A journey of a thousand miles begins with a single step. - Lao Tzu",
    "Focus on being productive instead of busy. - Tim Ferriss",
    "The greatest wealth is health. - Virgil",
    "Don't watch the clock; do what it does. Keep going. - Sam Levenson",
    "The best way to predict the future is to create it.",
    "Take care of your body. It’s the only place you have to live. - Jim Rohn",
    "The secret of getting ahead is getting started. - Mark Twain",
    "Small progress is still progress.",
  ];

  @override
  void initState() {
    super.initState();
    _startQuoteTimer();
  }

  void _startQuoteTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.self_improvement,
          size: 70,
          color: widget.primaryColor.withOpacity(0.8),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Container(
            key: ValueKey<int>(_currentQuoteIndex),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: widget.primaryColor, width: 1.5),
            ),
            child: Text(
              _quotes[_currentQuoteIndex],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 4. MAIN TIMER SCREEN (StatelessWidget - Uses Provider)
// -------------------------------------------------------------

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: size, color: color),
          onPressed: onPressed,
          tooltip: label,
        ),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<FocusTimerStateModel>(
      builder: (context, timerModel, child) {
        final remainingTime = timerModel.remainingTime;
        final totalPhaseDuration = timerModel.currentPhaseDuration;
        final isRunning = timerModel.isRunning;
        // NEW: Get the current goal from the model
        final currentGoal = timerModel.currentGoal;

        return Scaffold(
          appBar: AppBar(
            title: Text(timerModel.phaseTitle),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  /* TODO: Implement Configuration Screen */
                },
                tooltip: 'Configure Pomodoro',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: timerModel.resetTimer,
                tooltip: 'Reset Cycle',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // --- Motivational Character and Quote (ANIMATED) ---
                _QuoteCycler(primaryColor: primaryColor),

                const SizedBox(height: 30),

                // --- Cycle Progress Display ---
                Text(
                  '${timerModel.phaseTitle} ${timerModel.completedCycles + 1} of ${timerModel.cyclesBeforeLongBreak}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 10),

                // --- Timer Display (CIRCULAR) ---
                _ProgressCircleTimer(
                  remainingDuration: remainingTime,
                  totalPhaseDuration: totalPhaseDuration,
                  formattedTime: _formatDuration(remainingTime),
                  primaryColor: primaryColor,
                ),

                const SizedBox(height: 30),

                // --- Control Buttons ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mark Interruption Button
                    _buildControlButton(
                      icon: Icons.notifications_off_outlined,
                      label: 'Distraction (${timerModel.interruptionCount})',
                      color: Colors.red.withOpacity(0.7),
                      size: 40,
                      onPressed: timerModel.markInterruption,
                    ),
                    const SizedBox(width: 20),

                    // Play/Pause Button
                    _buildControlButton(
                      icon: isRunning
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      label: isRunning ? 'Pause' : 'Start',
                      color: primaryColor,
                      size: 80,
                      onPressed: isRunning
                          ? timerModel.pauseTimer
                          : timerModel.startTimer,
                    ),
                    const SizedBox(width: 20),

                    // Skip Phase Button (Calls public skipPhase method)
                    _buildControlButton(
                      icon: Icons.skip_next,
                      label: 'Skip',
                      color: Colors.orange,
                      size: 40,
                      onPressed: timerModel.skipPhase,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- Current Goal Setter (NEW IMPLEMENTATION) ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current Goal:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Use GestureDetector to make the goal area clickable
                GestureDetector(
                  onTap: () => _showGoalSetterDialog(context, timerModel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: currentGoal == 'No task currently linked.'
                          ? Colors.grey.withOpacity(0.1)
                          : primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: currentGoal == 'No task currently linked.'
                            ? Colors.grey.withOpacity(0.4)
                            : primaryColor,
                        width: 1,
                      ),
                    ),
                    width: double.infinity,
                    child: Text(
                      currentGoal,
                      style: TextStyle(
                        fontSize: 16,
                        color: currentGoal == 'No task currently linked.'
                            ? Colors.grey[700]
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Tap instruction text
                const Text(
                  'Tap above to link a task, pill reminder, or study goal.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
