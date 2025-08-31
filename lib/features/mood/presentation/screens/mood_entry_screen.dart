import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/theme/app_gradients.dart';
import 'package:lumina/features/mood/presentation/widgets/mood_selector.dart';
import 'package:lumina/shared/models/mood_entry.dart';
import 'package:lumina/shared/widgets/animated_button.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';
import 'package:lumina/shared/widgets/gradient_container.dart';
import 'package:lumina/shared/widgets/loading_overlay.dart';

class MoodEntryScreen extends ConsumerStatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  ConsumerState<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends ConsumerState<MoodEntryScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _fabController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  MoodType? selectedMood;
  int intensity = 5;
  String note = '';
  List<String> selectedFactors = [];
  bool isLoading = false;

  final PageController _stepController = PageController();
  final TextEditingController _noteController = TextEditingController();
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.elasticOut),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );

    _pageController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    _stepController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: isLoading,
        loadingText: 'Saving your mood...',
        child: GradientContainer(
          gradient: AppGradients.primary,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildProgressIndicator(),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStepContent(),
                    ),
                  ),
                ),
                _buildNavigationButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Spacer(),
          Text(
            _getStepTitle(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (currentStep) {
      case 0:
        return 'Your Mood';
      case 1:
        return 'What Influenced It?';
      case 2:
        return 'Add a Note';
      default:
        return '';
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= currentStep;
          final isCompleted = index < currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
              ),
              child: isCompleted
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: AppGradients.accent,
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    return PageView(
      controller: _stepController,
      physics: const NeverScrollableScrollPhysics(),
      children: [_buildMoodStep(), _buildFactorsStep(), _buildNoteStep()],
    );
  }

  Widget _buildMoodStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          MoodSelector(
            selectedMood: selectedMood,
            onMoodSelected: (mood) {
              setState(() {
                selectedMood = mood;
                intensity = mood.baseIntensity;
              });
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(height: 32),
          IntensitySlider(
            value: intensity,
            selectedMood: selectedMood,
            onChanged: (value) {
              setState(() {
                intensity = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'What influenced your mood today?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildFactorsGrid(),
        ],
      ),
    );
  }

  Widget _buildFactorsGrid() {
    final factors = MoodFactors.defaultFactors;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: factors.map((factor) {
        final isSelected = selectedFactors.contains(factor.id);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedFactors.remove(factor.id);
                } else {
                  selectedFactors.add(factor.id);
                }
              });
              HapticFeedback.selectionClick();
            },
            child: GlassMorphismCard(
              borderRadius: 20,
              color: isSelected
                  ? (factor.isPositive ? Colors.green : Colors.red).withValues(
                      alpha: 0.3,
                    )
                  : Colors.white.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(factor.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    factor.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoteStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Add a note about your day',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            '(Optional)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          GlassMorphismCard(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _noteController,
              maxLines: 6,
              maxLength: 500,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'How was your day? What made you feel this way?',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                counterStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: (value) {
                setState(() {
                  note = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: AnimatedButton(
                onPressed: _previousStep,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Back'),
                  ],
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: AnimatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              gradient: AppGradients.primary,
              isEnabled: _canProceed(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(currentStep == 2 ? 'Save Mood' : 'Next'),
                  const SizedBox(width: 8),
                  Icon(currentStep == 2 ? Icons.save : Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0:
        return selectedMood != null;
      case 1:
        return true; // Factors are optional
      case 2:
        return true; // Note is optional
      default:
        return false;
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _stepController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
      _stepController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveMoodEntry();
    }
  }

  Future<void> _saveMoodEntry() async {
    if (selectedMood == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Save to Firestore using MoodService
      // For now, just simulate saving

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        HapticFeedback.mediumImpact();
        context.pop();
        // TODO: Show success message
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        // TODO: Show error message
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
