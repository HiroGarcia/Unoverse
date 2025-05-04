import 'package:flutter/material.dart';
import 'package:unoverse/domain/entity/user_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserService userService = UserService();

  late User user;
  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unoverse Groups'),
        actions: [
          IconButton(
            onPressed: () async {
              print('--------------');
              print('Nome: ${user.name}');
              print('Email: ${user.email}');
              print('Avatar: ${user.avatar}');
              print('Grupos: ${user.groupsId}');
            },
            icon: Icon(Icons.mode_edit_sharp),
            color: Colors.black,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      drawer: Drawer(),
      body: Container(
        color: Colors.blue[50],
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.amber,
              child: Center(child: Text('Group $index')),
            );
          },
        ),
      ),
    );
  }

  refresh() async {
    User usertemp = await userService.readUser();

    setState(() {
      user = usertemp;
    });
  }
}
