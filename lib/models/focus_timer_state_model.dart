// lib/models/focus_timer_state_model.dart

import 'dart:async';
import 'package:flutter/material.dart';

// Enum to represent the current state of the timer cycle
enum TimerPhase { focus, shortBreak, longBreak, idle }

class FocusTimerStateModel with ChangeNotifier {
  // --- Configuration (Can be customized by the user later) ---
  final Duration _workDuration = const Duration(minutes: 25);
  final Duration _shortBreakDuration = const Duration(minutes: 5);
  final Duration _longBreakDuration = const Duration(minutes: 15);
  final int _cyclesBeforeLongBreak = 4;
  // ADD THIS PRIVATE VARIABLE:
  final Duration _currentPhaseDuration = const Duration(
    minutes: 25,
  ); // Default value
  // ADD THIS PUBLIC GETTER: (This is what TimerScreen is looking for)
  Duration get currentPhaseDuration => _currentPhaseDuration;

  // --- Current State ---
  Duration _remainingTime = const Duration(minutes: 25);
  TimerPhase _currentPhase = TimerPhase.idle;
  int _completedCycles = 0; // Number of completed focus sessions in a block
  int _interruptionCount = 0; // Tracking distractions

  Timer? _timer;

  // --- Getters for UI access ---
  Duration get remainingTime => _remainingTime;
  TimerPhase get currentPhase => _currentPhase;
  String get phaseTitle {
    switch (_currentPhase) {
      case TimerPhase.focus:
        return 'Focus Time';
      case TimerPhase.shortBreak:
        return 'Short Break';
      case TimerPhase.longBreak:
        return 'Long Break';
      case TimerPhase.idle:
        return 'Ready to Focus';
    }
  }

  bool get isRunning => _timer != null && _timer!.isActive;
  int get completedCycles => _completedCycles;
  int get cyclesBeforeLongBreak => _cyclesBeforeLongBreak;
  int get interruptionCount => _interruptionCount;

  // --- Constructor and Disposal ---
  FocusTimerStateModel() {
    _remainingTime = _workDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // NEW: State for tracking the current goal
  String _currentGoal = 'No task currently linked.';

  // NEW: Getter for the current goal
  String get currentGoal => _currentGoal;

  // NEW: Method to update the goal
  void setGoal(String newGoal) {
    if (newGoal.trim().isNotEmpty) {
      _currentGoal = newGoal;
    } else {
      // Revert to default if input is empty
      _currentGoal = 'No task currently linked.';
    }
    notifyListeners(); // Notify listeners (TimerScreen) of the change
  }

  // --- Timer Controls ---

  void startTimer() {
    if (isRunning) return;
    if (_currentPhase == TimerPhase.idle) {
      _currentPhase = TimerPhase.focus;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
      } else {
        _moveToNextPhase();
        _timer?.cancel();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _remainingTime = _workDuration;
    _currentPhase = TimerPhase.idle;
    _completedCycles = 0;
    _interruptionCount = 0;
    notifyListeners();
  }

  void markInterruption() {
    _interruptionCount++;
    notifyListeners();
  }

  void skipPhase() {
    // Cancel the current timer, then move to the next phase
    _timer?.cancel();
    _moveToNextPhase();
    // _moveToNextPhase() internally calls startTimer()
  }

  // --- Pomodoro Cycle Logic ---

  void _moveToNextPhase() {
    if (_currentPhase == TimerPhase.focus) {
      _completedCycles++;
      // Check if it's time for a long break
      if (_completedCycles % _cyclesBeforeLongBreak == 0) {
        _currentPhase = TimerPhase.longBreak;
        _remainingTime = _longBreakDuration;
      } else {
        _currentPhase = TimerPhase.shortBreak;
        _remainingTime = _shortBreakDuration;
      }
    } else if (_currentPhase == TimerPhase.shortBreak ||
        _currentPhase == TimerPhase.longBreak) {
      _currentPhase = TimerPhase.focus;
      _remainingTime = _workDuration;
    }
    // Automatically start the next phase (Auto-Start Next feature)
    startTimer();
  }

  // --- Utility Methods (To be implemented in UI for display) ---

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
