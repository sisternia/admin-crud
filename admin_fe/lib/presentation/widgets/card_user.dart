// lib/presentation/widgets/card_user.dart
import 'package:flutter/material.dart';
import '../../core/constants/api.dart';
import '../../data/models/user_model.dart';
import '../screens/edit_screen.dart';
import '../screens/detail_screen.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final bool isDeleteMode;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onUpdated;
  final int? reorderIndex; // ✅ thêm dòng này

  const UserCard({
    super.key,
    required this.user,
    this.isDeleteMode = false,
    this.isEditMode = false,
    this.isSelected = false,
    this.onSelect,
    this.onUpdated,
    this.reorderIndex,
  });

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (user.image != null && user.image!.isNotEmpty) {
      imageUrl = user.image!.startsWith('/assets/')
          ? '${ApiConstants.baseUrl}${user.image}'
          : '${ApiConstants.assetUrl}/${user.image}';
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.bottomCenter, // ✅ để icon nằm dưới
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person,
                                size: 50, color: Colors.deepPurple),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person,
                              size: 50, color: Colors.deepPurple),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.username,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (isDeleteMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onSelect?.call(),
                  )
                else if (isEditMode)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditScreen(user: user),
                        ),
                      );
                      onUpdated?.call();
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.priority_high,
                        color: Colors.deepPurple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(user: user),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // ✅ Icon kéo thả nằm giữa mép dưới
          if (reorderIndex != null)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: ReorderableDragStartListener(
                  index: reorderIndex!,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.drag_handle,
                      color: Colors.deepPurple,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
