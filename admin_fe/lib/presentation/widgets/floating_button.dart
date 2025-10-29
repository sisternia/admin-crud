// lib\presentation\widgets\floating_button.dart
import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {
  final bool isMenuOpen;
  final bool isDeleteMode;
  final IconData mainIcon;
  final VoidCallback onLongPress;
  final VoidCallback onPressed;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<IconData> onChangeMainIcon; // Callback đổi icon

  const CustomFloatingButton({
    super.key,
    required this.isMenuOpen,
    required this.isDeleteMode,
    required this.mainIcon,
    required this.onLongPress,
    required this.onPressed,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onChangeMainIcon,
  });

  Widget _buildMenuButton(IconData icon, String tooltip, VoidCallback action) {
    return Container(
      height: 50,
      width: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: FloatingActionButton(
        heroTag: tooltip,
        onPressed: () {
          onChangeMainIcon(icon); // đổi icon trước
          Future.delayed(const Duration(milliseconds: 150),
              action); // delay để thấy icon đổi trước khi thực hiện chức năng
        },
        tooltip: tooltip,
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMenuOpen) ...[
          _buildMenuButton(Icons.add, 'Add', onAdd),
          _buildMenuButton(Icons.edit, 'Edit', onEdit),
          _buildMenuButton(Icons.delete, 'Delete', onDelete),
        ],
        GestureDetector(
          onLongPress: onLongPress,
          child: FloatingActionButton(
            heroTag: 'main',
            onPressed: onPressed,
            backgroundColor: Colors.deepPurple,
            child: Icon(
              isMenuOpen
                  ? Icons.close
                  : isDeleteMode
                      ? Icons.delete
                      : mainIcon,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
