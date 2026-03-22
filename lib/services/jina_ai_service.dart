import 'package:http/http.dart' as http;

class JinaAIService {
  static Future<Map<String, dynamic>> processUrl(String url) async {
    try {
      final jinaUrl = Uri.parse('https://r.jina.ai/$url');

      final response = await http.get(
        jinaUrl,
        headers: {
          'Accept': 'text/plain',
          'X-Return-Format': 'markdown',
          'X-Timeout': '30',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final rawContent = response.body;

        if (rawContent.isEmpty) {
          throw Exception('No content extracted from this link.');
        }

        return {
          'title': _extractTitle(rawContent),
          'content': rawContent,
          'summary': _makeSummary(rawContent),
          'tags': [_autoTag(rawContent)],
          'deadline': _detectDeadline(rawContent),
          'sourceUrl': url,
        };
      } else if (response.statusCode == 403) {
        throw Exception('This website blocks content extraction.');
      } else if (response.statusCode == 404) {
        throw Exception('Page not found. Check the URL.');
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Network error. Check your internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  static String _extractTitle(String content) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();

    for (final line in lines) {
      if (line.startsWith('#')) {
        return line.replaceAll(RegExp(r'#+'), '').trim();
      }
    }

    return lines.isNotEmpty ? lines.first.trim() : 'Untitled Note';
  }

  static String _makeSummary(String content) {
    final clean = content
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'\*{1,2}(.*?)\*{1,2}'), r'$1')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '')
        .replaceAll(RegExp(r'`{1,3}[^`]*`{1,3}'), '')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    final words = clean.split(' ').where((w) => w.isNotEmpty).toList();

    if (words.length <= 150) return clean;

    return '${words.take(150).join(' ')}...';
  }

  static String _autoTag(String text) {
    final t = text.toLowerCase();

    final tagMap = {
      'Technology': ['flutter', 'programming', 'code', 'software', 'developer', 'api', 'android', 'ios', 'javascript', 'python', 'ai', 'machine learning', 'github', 'tech', 'cloud', 'database'],
      'Science': ['science', 'biology', 'physics', 'chemistry', 'research', 'space', 'nasa', 'quantum', 'experiment', 'study'],
      'Business': ['business', 'startup', 'entrepreneur', 'marketing', 'sales', 'revenue', 'strategy', 'saas', 'product'],
      'Finance': ['money', 'invest', 'stock', 'crypto', 'finance', 'budget', 'wealth', 'trading', 'economy', 'mutual fund', 'nifty', 'sensex'],
      'Health': ['health', 'fitness', 'workout', 'diet', 'nutrition', 'mental health', 'exercise', 'yoga', 'calories', 'doctor', 'medical'],
      'Career': ['job', 'resume', 'interview', 'career', 'hiring', 'salary', 'internship', 'placement', 'fresher', 'recruiter'],
      'Education': ['learn', 'study', 'course', 'tutorial', 'education', 'skill', 'lecture', 'university', 'exam', 'notes', 'cbse'],
      'Motivation': ['motivation', 'mindset', 'success', 'goals', 'habits', 'discipline', 'inspire', 'growth', 'self improvement'],
      'Design': ['design', 'ui', 'ux', 'figma', 'graphic', 'creative', 'branding', 'color', 'typography', 'wireframe', 'prototype'],
      'Productivity': ['productivity', 'focus', 'time management', 'efficiency', 'notion', 'organize', 'workflow', 'pomodoro', 'deep work'],
      'News': ['breaking', 'news', 'today', 'report', 'government', 'politics', 'election', 'minister', 'policy', 'india'],
    };

    for (final entry in tagMap.entries) {
      if (entry.value.any((kw) => t.contains(kw))) {
        return entry.key;
      }
    }
    return 'Other';
  }

  static String? _detectDeadline(String text) {
    final patterns = [
      RegExp(r'apply\s+by[:\s]+(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})', caseSensitive: false),
      RegExp(r'deadline[:\s]+(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})', caseSensitive: false),
      RegExp(r'last\s+date[:\s]+(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})', caseSensitive: false),
      RegExp(r'closes?\s+on[:\s]+(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})', caseSensitive: false),
      RegExp(r'(\d{4}-\d{2}-\d{2})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1);
    }
    return null;
  }
}
