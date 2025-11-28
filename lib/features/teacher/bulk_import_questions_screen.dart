import 'package:flutter/material.dart';
import '../../services/exam_service.dart';

class BulkImportQuestionsScreen extends StatefulWidget {
  final String examId;
  const BulkImportQuestionsScreen({super.key, required this.examId});

  @override
  State<BulkImportQuestionsScreen> createState() => _BulkImportQuestionsScreenState();
}

class _BulkImportQuestionsScreenState extends State<BulkImportQuestionsScreen> {
  List<Map<String, dynamic>> _parsedQuestions = [];
  bool _loading = false;
  final _textController = TextEditingController();
  final _examService = ExamService();
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  
  void _parseText() {
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Masukkan text soal terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _loading = true);
    
    try {
      // Parse questions
      final questions = _parseQuestions(text);
      
      setState(() {
        _parsedQuestions = questions;
        _loading = false;
      });
      
      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Tidak ada soal yang terdeteksi. Pastikan format sesuai.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Berhasil mendeteksi ${questions.length} soal'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  List<Map<String, dynamic>> _parseQuestions(String text) {
    final questions = <Map<String, dynamic>>[];
    
    // Split by question numbers (1., 2., 3., etc.)
    final questionBlocks = text.split(RegExp(r'\n\d+\.\s'));
    
    for (int i = 1; i < questionBlocks.length; i++) {
      final block = questionBlocks[i].trim();
      
      try {
        // Extract question text (before options)
        final questionMatch = RegExp(r'^(.+?)\nA\.', dotAll: true).firstMatch(block);
        if (questionMatch == null) continue;
        
        final questionText = questionMatch.group(1)!.trim();
        
        // Extract options
        final optionA = RegExp(r'A\.\s*(.+?)(?:\n|$)').firstMatch(block)?.group(1)?.trim();
        final optionB = RegExp(r'B\.\s*(.+?)(?:\n|$)').firstMatch(block)?.group(1)?.trim();
        final optionC = RegExp(r'C\.\s*(.+?)(?:\n|$)').firstMatch(block)?.group(1)?.trim();
        final optionD = RegExp(r'D\.\s*(.+?)(?:\n|$)').firstMatch(block)?.group(1)?.trim();
        
        // Extract correct answer
        final answerMatch = RegExp(r'Jawaban:\s*([A-D])', caseSensitive: false).firstMatch(block);
        final correctAnswer = answerMatch?.group(1)?.toUpperCase();
        
        if (optionA != null && optionB != null && optionC != null && 
            optionD != null && correctAnswer != null) {
          questions.add({
            'question_text': questionText,
            'options': [optionA, optionB, optionC, optionD],
            'correct_answer': correctAnswer,
            'order_index': i - 1,
          });
        }
      } catch (e) {
        print('Error parsing question $i: $e');
      }
    }
    
    return questions;
  }
  
  Future<void> _importQuestions() async {
    if (_parsedQuestions.isEmpty) return;
    
    setState(() => _loading = true);
    
    try {
      for (final question in _parsedQuestions) {
        await _examService.addQuestion(widget.examId, {
          'question_type': 'multiple_choice',
          'question_text': question['question_text'],
          'options': question['options'],
          'correct_answer': question['correct_answer'],
          'order_index': question['order_index'],
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Berhasil import ${_parsedQuestions.length} soal!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      appBar: AppBar(
        title: const Text('Bulk Import Soal'),
        backgroundColor: const Color(0xFF7C7CFF),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Instructions
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7C7CFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7C7CFF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF7C7CFF)),
                      SizedBox(width: 8),
                      Text(
                        'Format Text yang Didukung',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C7CFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Apa ibukota Indonesia?\n'
                    'A. Jakarta\n'
                    'B. Bandung\n'
                    'C. Surabaya\n'
                    'D. Yogyakarta\n'
                    'Jawaban: A\n\n'
                    '2. Berapa hasil 2 + 2?\n'
                    'A. 3\n'
                    'B. 4\n'
                    'C. 5\n'
                    'D. 6\n'
                    'Jawaban: B',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            // Text Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Paste soal di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2D2D44) : Colors.grey[100],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Parse Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _parseText,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Parse Soal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C7CFF),
                  ),
                ),
              ),
            ),
            
            if (_loading && _parsedQuestions.isEmpty)
              const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memproses text...'),
                    ],
                  ),
                ),
              )
            else if (_parsedQuestions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ditemukan ${_parsedQuestions.length} soal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _parsedQuestions = [];
                          _textController.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _parsedQuestions.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final q = _parsedQuestions[index];
                  return Card(
                    color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C7CFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Soal ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            q['question_text'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(4, (i) {
                            final letter = String.fromCharCode(65 + i);
                            final isCorrect = q['correct_answer'] == letter;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isCorrect 
                                          ? Colors.green 
                                          : Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        letter,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isCorrect 
                                              ? Colors.white 
                                              : Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      q['options'][i],
                                      style: TextStyle(
                                        fontWeight: isCorrect 
                                            ? FontWeight.w600 
                                            : FontWeight.normal,
                                        color: isCorrect 
                                            ? Colors.green 
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (isCorrect)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _importQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Import Semua Soal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ] else
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Paste text soal untuk memulai',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
