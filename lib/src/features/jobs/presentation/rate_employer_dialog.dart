// lib/src/features/jobs/presentation/rate_employer_dialog.dart
import 'package:flutter/material.dart';
import '../../jobs/domain/job_models.dart';

class RatingResult {
  final int stars;
  final String? comment;
  const RatingResult(this.stars, this.comment);
}

class RateEmployerDialog extends StatefulWidget {
  final Job job;
  const RateEmployerDialog({super.key, required this.job});

  @override
  State<RateEmployerDialog> createState() => _RateEmployerDialogState();
}

class _RateEmployerDialogState extends State<RateEmployerDialog> {
  int _stars = 5;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.job.companyName} için değerlendirme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 4,
            children: List.generate(5, (i) {
              final idx = i + 1;
              final filled = idx <= _stars;
              return IconButton(
                icon: Icon(filled ? Icons.star : Icons.star_border),
                onPressed: () => setState(() => _stars = idx),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Yorumun (opsiyonel)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
        ElevatedButton(
          onPressed: () {
            final text = _controller.text.trim();
            Navigator.pop<RatingResult>(
              context,
              RatingResult(_stars, text.isEmpty ? null : text),
            );
          },
          child: const Text('Gönder'),
        ),
      ],
    );
  }
}
