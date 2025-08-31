import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lumina/features/analytics/data/services/insights_service.dart';
import 'package:lumina/shared/models/analytics_models.dart';

class ExportService {
  static const String _appName = 'Lumina';
  static const String _tagline = 'Your Wellness Journey';

  /// Export analytics data as PDF
  Future<void> exportAnalyticsPDF({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required MoodStatistics moodStats,
    required JournalStatistics journalStats,
    required List<Insight> insights,
    String? customTitle,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Create PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildPdfHeader(customTitle),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            _buildPdfSummary(moodStats, journalStats, startDate, endDate),
            pw.SizedBox(height: 20),
            _buildPdfMoodSection(moodStats),
            pw.SizedBox(height: 20),
            _buildPdfJournalSection(journalStats),
            pw.SizedBox(height: 20),
            _buildPdfInsightsSection(insights),
          ],
        ),
      );

      // Save and share PDF
      final bytes = await pdf.save();
      await _savePdfAndShare(bytes, 'analytics_export_${_formatDateForFile(DateTime.now())}');
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  /// Export specific chart or widget as image
  Future<void> exportWidgetAsImage({
    required Widget widget,
    required String fileName,
    double pixelRatio = 3.0,
    Size? size,
  }) async {
    // For now, we'll use a placeholder approach
    // In a real implementation, this would need to be integrated with the widget tree
    throw UnimplementedError('Widget to image export needs to be implemented with proper widget tree integration');
  }

  /// Create shareable analytics card
  Future<void> createShareableCard({
    required MoodStatistics moodStats,
    required JournalStatistics journalStats,
    required String period,
    String? customMessage,
  }) async {
    // For now, this is a placeholder implementation
    // In a real implementation, this would generate and share a card image
    throw UnimplementedError('Shareable card creation needs widget tree integration');
  }

  /// Share text-based analytics summary
  Future<void> shareTextSummary({
    required MoodStatistics moodStats,
    required JournalStatistics journalStats,
    required List<Insight> insights,
    required String period,
  }) async {
    try {
      final summary = _buildTextSummary(moodStats, journalStats, insights, period);
      await SharePlus.instance.share(
        ShareParams(
          text: summary,
          subject: '$_appName - My Wellness Summary ($period)',
        ),
      );
    } catch (e) {
      throw Exception('Failed to share text summary: $e');
    }
  }

  // PDF Building Methods
  pw.Widget _buildPdfHeader(String? customTitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                customTitle ?? '$_appName Analytics',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _tagline,
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Text(
            'Generated on ${_formatDateForDisplay(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount} • $_appName',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey500,
        ),
      ),
    );
  }

  pw.Widget _buildPdfSummary(
    MoodStatistics moodStats,
    JournalStatistics journalStats,
    DateTime startDate,
    DateTime endDate,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.deepPurple,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Period: ${_formatDateForDisplay(startDate)} - ${_formatDateForDisplay(endDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildPdfStatCard(
                  'Mood Entries',
                  '${moodStats.totalEntries}',
                  'Total recordings',
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildPdfStatCard(
                  'Average Mood',
                  '${moodStats.averageMood.toStringAsFixed(1)}/10',
                  'Overall wellbeing',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildPdfStatCard(
                  'Journal Entries',
                  '${journalStats.totalEntries}',
                  'Written reflections',
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildPdfStatCard(
                  'Current Streak',
                  '${journalStats.currentStreak} days',
                  'Consecutive journaling',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStatCard(String title, String value, String subtitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.deepPurple,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfMoodSection(MoodStatistics moodStats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Mood Analysis',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.deepPurple,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey200),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• Highest mood: ${moodStats.highestMood.toStringAsFixed(1)}/10'),
              pw.SizedBox(height: 4),
              pw.Text('• Lowest mood: ${moodStats.lowestMood.toStringAsFixed(1)}/10'),
              pw.SizedBox(height: 4),
              pw.Text('• Mood stability: ${_calculateMoodStability(moodStats)}'),
              pw.SizedBox(height: 4),
              pw.Text('• Most frequent mood: ${moodStats.mostFrequentMood?.displayName ?? 'N/A'}'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfJournalSection(JournalStatistics journalStats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Journal Analysis',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.deepPurple,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey200),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• Average words per entry: ${journalStats.averageWordsPerEntry.toStringAsFixed(0)}'),
              pw.SizedBox(height: 4),
              pw.Text('• Longest streak: ${journalStats.longestStreak} days'),
              pw.SizedBox(height: 4),
              pw.Text('• Total gratitude items: ${journalStats.totalGratitudeEntries}'),
              pw.SizedBox(height: 4),
              pw.Text('• Writing frequency: ${(journalStats.writingFrequency * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfInsightsSection(List<Insight> insights) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Key Insights',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.deepPurple,
          ),
        ),
        pw.SizedBox(height: 12),
        ...insights.take(5).map(
          (insight) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _getPdfColorForInsightType(insight.type),
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  insight.title,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  insight.description,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (insight.suggestion != null) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '💡 ${insight.suggestion}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Text Summary
  String _buildTextSummary(
    MoodStatistics moodStats,
    JournalStatistics journalStats,
    List<Insight> insights,
    String period,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('🌟 My $_appName Wellness Summary');
    buffer.writeln('Period: $period');
    buffer.writeln('');
    
    // Mood stats
    buffer.writeln('📊 Mood Tracking:');
    buffer.writeln('• ${moodStats.totalEntries} mood entries recorded');
    buffer.writeln('• Average mood: ${moodStats.averageMood.toStringAsFixed(1)}/10');
    buffer.writeln('• Highest mood: ${moodStats.highestMood.toStringAsFixed(1)}/10');
    buffer.writeln('• Most frequent: ${moodStats.mostFrequentMood?.displayName ?? 'N/A'}');
    buffer.writeln('');
    
    // Journal stats
    buffer.writeln('📝 Journaling:');
    buffer.writeln('• ${journalStats.totalEntries} journal entries');
    buffer.writeln('• Current streak: ${journalStats.currentStreak} days');
    buffer.writeln('• Average words: ${journalStats.averageWordsPerEntry.toStringAsFixed(0)} per entry');
    buffer.writeln('• Gratitude items: ${journalStats.totalGratitudeEntries}');
    buffer.writeln('');
    
    // Key insights
    buffer.writeln('💡 Key Insights:');
    for (final insight in insights.take(3)) {
      buffer.writeln('• ${insight.title}: ${insight.description}');
    }
    buffer.writeln('');
    
    buffer.writeln('Generated with $_appName - $_tagline');
    
    return buffer.toString();
  }

  // Helper Methods
  Future<void> _savePdfAndShare(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: '$_appName Analytics Export',
      ),
    );
  }

  // _saveImageAndShare method removed as it's not currently used
  // Will be re-implemented when widget-to-image functionality is properly integrated

  String _formatDateForFile(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateForDisplay(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _calculateMoodStability(MoodStatistics stats) {
    final range = stats.highestMood - stats.lowestMood;
    if (range < 2) return 'Very Stable';
    if (range < 4) return 'Stable';
    if (range < 6) return 'Moderate';
    return 'Variable';
  }

  PdfColor _getPdfColorForInsightType(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return PdfColors.green50;
      case InsightType.warning:
        return PdfColors.orange50;
      case InsightType.neutral:
        return PdfColors.grey50;
      case InsightType.achievement:
        return PdfColors.purple50;
    }
  }
}