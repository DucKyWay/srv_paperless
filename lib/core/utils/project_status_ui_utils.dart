import 'package:flutter/material.dart';
import '../constants/project_status_enum.dart';

extension ProjectStatusUI on ProjectStatus? {
  Color get backgroundColor {
    switch (this) {
      case ProjectStatus.draft:
        return Colors.blue.shade50;
      case ProjectStatus.pending:
        return Colors.orange.shade50;
      case ProjectStatus.approve:
        return Colors.green.shade50;
      case ProjectStatus.started:
        return Colors.purple.shade50;
      case ProjectStatus.finished:
        return Colors.teal.shade50;
      case ProjectStatus.rejected:
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color get mainColor {
    switch (this) {
      case ProjectStatus.draft:
        return Colors.blue.shade700;
      case ProjectStatus.pending:
        return Colors.orange.shade700;
      case ProjectStatus.approve:
        return Colors.green.shade700;
      case ProjectStatus.started:
        return Colors.purple.shade700;
      case ProjectStatus.finished:
        return Colors.teal.shade700;
      case ProjectStatus.rejected:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color get borderColor {
    switch (this) {
      case ProjectStatus.draft:
        return Colors.blue.shade300;
      case ProjectStatus.pending:
        return Colors.orange.shade300;
      case ProjectStatus.approve:
        return Colors.green.shade300;
      case ProjectStatus.started:
        return Colors.purple.shade300;
      case ProjectStatus.finished:
        return Colors.teal.shade300;
      case ProjectStatus.rejected:
        return Colors.red.shade300;
      default:
        return Colors.black12;
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectStatus.draft:
        return Icons.edit_note_rounded;
      case ProjectStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ProjectStatus.approve:
        return Icons.check_circle_outline_rounded;
      case ProjectStatus.started:
        return Icons.play_circle_outline_rounded;
      case ProjectStatus.finished:
        return Icons.task_alt_rounded;
      case ProjectStatus.rejected:
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
