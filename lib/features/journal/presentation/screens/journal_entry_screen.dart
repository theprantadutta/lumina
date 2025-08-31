import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumina/core/theme/app_gradients.dart';
import 'package:lumina/features/journal/presentation/widgets/rich_text_editor.dart';
import 'package:lumina/shared/models/journal_entry.dart';
import 'package:lumina/shared/widgets/animated_button.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';
import 'package:lumina/shared/widgets/gradient_container.dart';
import 'package:lumina/shared/widgets/loading_overlay.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  final JournalTemplate? template;
  final String? entryId; // For editing existing entry

  const JournalEntryScreen({super.key, this.template, this.entryId});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _fabController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _titleController = TextEditingController();
  String _content = '';
  JournalTemplate _selectedTemplate = JournalTemplate.freeform;
  JournalMood _selectedMood = JournalMood.neutral;
  final List<String> _tags = [];
  final List<String> _imageUrls = [];
  final List<Gratitude> _gratitudeList = [];
  bool _isLoading = false;
  bool _isFavorite = false;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  String? _currentPrompt;

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
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.elasticOut),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );

    _selectedTemplate = widget.template ?? JournalTemplate.freeform;
    _generateRandomPrompt();
    _pageController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    _titleController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _generateRandomPrompt() {
    setState(() {
      _currentPrompt = JournalPrompts.getRandomPrompt(_selectedTemplate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        loadingText: 'Saving your journal entry...',
        child: GradientContainer(
          gradient: AppGradients.primary,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabController,
        child: FloatingActionButton.extended(
          onPressed: _saveEntry,
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          icon: const Icon(Icons.save),
          label: const Text('Save Entry'),
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
          Expanded(
            child: Text(
              widget.entryId != null ? 'Edit Entry' : 'New Journal Entry',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTemplateSelector(),
          const SizedBox(height: 16),
          _buildPromptCard(),
          const SizedBox(height: 16),
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildMoodSelector(),
          const SizedBox(height: 16),
          _buildContentEditor(),
          const SizedBox(height: 16),
          if (_selectedTemplate == JournalTemplate.gratitude)
            _buildGratitudeSection(),
          _buildImageSection(),
          const SizedBox(height: 16),
          _buildTagsSection(),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Template',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showTemplateSelector,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedTemplate.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTemplate.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    if (_currentPrompt == null) return const SizedBox.shrink();

    return GlassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Writing Prompt',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _generateRandomPrompt,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentPrompt!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintText: 'Enter a title for your entry...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.title, color: Colors.white70),
        ),
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _contentFocusNode.requestFocus(),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mood, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'How are you feeling?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: JournalMood.values.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood;
                  });
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood.color.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? mood.color : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mood.emoji,
                        style: TextStyle(fontSize: isSelected ? 18 : 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mood.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: isSelected ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentEditor() {
    return SizedBox(
      height: 300,
      child: SimpleTextEditor(
        onContentChanged: (content) {
          _content = content;
        },
        hint: _currentPrompt ?? 'Start writing your thoughts...',
        focusNode: _contentFocusNode,
      ),
    );
  }

  Widget _buildGratitudeSection() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Gratitude List',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._gratitudeList.asMap().entries.map((entry) {
            final index = entry.key;
            final gratitude = entry.value;
            return _buildGratitudeItem(gratitude, index);
          }),
          const SizedBox(height: 8),
          Center(
            child: AnimatedButton(
              onPressed: _addGratitudeItem,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Add Gratitude'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGratitudeItem(Gratitude gratitude, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gratitude.category.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gratitude.category.color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            gratitude.category.icon,
            color: gratitude.category.color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              gratitude.text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () => _removeGratitudeItem(index),
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_outlined, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Images',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _addImage,
                icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (_imageUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.white70),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tag, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Tags',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _addTag,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$tag',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose Template',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: JournalTemplate.values.length,
                itemBuilder: (context, index) {
                  final template = JournalTemplate.values[index];
                  final isSelected = _selectedTemplate == template;

                  return ListTile(
                    leading: Icon(
                      template.icon,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    title: Text(
                      template.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      template.description,
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: Colors.white.withValues(alpha: 0.1),
                    onTap: () {
                      setState(() {
                        _selectedTemplate = template;
                      });
                      _generateRandomPrompt();
                      Navigator.pop(context);
                      HapticFeedback.selectionClick();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addGratitudeItem() {
    // For now, add a simple text input dialog
    showDialog(
      context: context,
      builder: (context) {
        String gratitudeText = '';
        GratitudeCategory selectedCategory = GratitudeCategory.simpleJoys;

        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Add Gratitude',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'What are you grateful for?',
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                onChanged: (value) => gratitudeText = value,
              ),
              const SizedBox(height: 16),
              DropdownButton<GratitudeCategory>(
                value: selectedCategory,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                items: GratitudeCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 8),
                        Text(category.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => selectedCategory = value!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                if (gratitudeText.isNotEmpty) {
                  setState(() {
                    _gratitudeList.add(
                      Gratitude(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        text: gratitudeText,
                        category: selectedCategory,
                        createdAt: DateTime.now(),
                      ),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _removeGratitudeItem(int index) {
    setState(() {
      _gratitudeList.removeAt(index);
    });
  }

  Future<void> _addImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      // For now, just add a placeholder URL
      // In a real app, you'd upload to Firebase Storage
      setState(() {
        _imageUrls.add(image.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        String tagText = '';
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Add Tag', style: TextStyle(color: Colors.white)),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter tag name',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            onChanged: (value) => tagText = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                if (tagText.isNotEmpty && !_tags.contains(tagText)) {
                  setState(() {
                    _tags.add(tagText);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty && _content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a title or content before saving'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual save to Firestore
      // final journalEntry = JournalEntry(
      //   id: widget.entryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      //   userId: 'current-user', // TODO: Get from auth
      //   title: _titleController.text,
      //   content: _content,
      //   tags: _tags,
      //   imageUrls: _imageUrls,
      //   gratitudeList: _gratitudeList,
      //   timestamp: DateTime.now(),
      //   createdAt: DateTime.now(),
      //   updatedAt: DateTime.now(),
      //   isFavorite: _isFavorite,
      //   mood: _selectedMood,
      //   template: _selectedTemplate,
      // );

      // Simulate save delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry saved!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
