import 'package:flutter/cupertino.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmDeleteDialog({
    super.key,
    this.title = 'Confirmar exclusão',
    this.content = 'Tem certeza que deseja excluir?',
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) onCancel!();
          },
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          child: const Text('Excluir'),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }
}

Future<void> showConfirmDeleteDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
  String title = 'Confirmar exclusão',
  String content = 'Tem certeza que deseja excluir?',
  VoidCallback? onCancel,
}) {
  return showCupertinoDialog(
    context: context,
    builder:
        (context) => ConfirmDeleteDialog(
          title: title,
          content: content,
          onConfirm: onConfirm,
          onCancel: onCancel,
        ),
  );
}
