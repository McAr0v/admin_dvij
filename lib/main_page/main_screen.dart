import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainPageCustom extends StatefulWidget {
  const MainPageCustom({Key? key}) : super(key: key);

  @override
  State<MainPageCustom> createState() => _MainPageCustomState();
}

class _MainPageCustomState extends State<MainPageCustom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vertical and Horizontal Scrolling'),
      ),
      drawer: CustomDrawer(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
                ListTile(title: Text('Item 3')),
                ListTile(title: Text('Item 4')),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                    width: 200.0,
                    color: Colors.red,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Center(child: Text('Horizontal Item 1')),
                  ),
                  Container(
                    width: 200.0,
                    color: Colors.blue,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Center(child: Text('Horizontal Item 2')),
                  ),
                  Container(
                    width: 200.0,
                    color: Colors.green,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Center(child: Text('Horizontal Item 3')),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
                ListTile(title: Text('Item 3')),
                ListTile(title: Text('Item 4')),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                    width: 200.0,
                    color: Colors.red,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Center(child: Text('Horizontal Item 1')),
                  ),
                  Container(
                    width: 200.0,
                    color: Colors.blue,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Center(child: Text('Horizontal Item 2')),
                  ),
                  Container(
                    width: 200.0,
                    color: Colors.green,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Center(child: Text('Horizontal Item 3')),
                  ),
                ],
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.teal[100 * (index % 9)],
                  child: Text('Grid Item $index'),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}
