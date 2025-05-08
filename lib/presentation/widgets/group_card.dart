import 'package:flutter/material.dart';

import '../../domain/entity/group_entity.dart';
import '../pages/group/group_page.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupPage(group: group)),
        );
      },
      child: Card(
        color: Colors.amber,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                group.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('ID: ${group.groupId}'),
            ],
          ),
        ),
      ),
    );
  }
}
