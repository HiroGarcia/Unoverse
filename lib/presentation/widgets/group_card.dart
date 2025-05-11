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
      onLongPress: () {},
      child: Card(
        elevation: 3,
        // color: Colors.blueGrey[200],
        color: Theme.of(context).colorScheme.secondary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                group.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
