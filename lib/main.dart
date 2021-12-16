import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home()
      );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Database? database;
  List<Map<String, Object?>> entries = [];

  @override
  void initState(){
    initDb();
    super.initState();
  }

  void initDb() async{
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + 'demo.db';


    // open the database
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
        });

    // Insert some records in a transaction
    await database!.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
      print('inserted1: $id1');
      int id2 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
          ['another name', 12345678, 3.1416]);
      print('inserted2: $id2');
    });
  }

  void getEntries() async{
    List<Map<String, Object?>> list = await database!.rawQuery('SELECT * FROM Test');
    entries = list;
    print(list);

  }

  // ignore: avoid_types_as_parameter_names
  void insertEntries(String name, int value, int num) async {
    int id1 = await database!.rawInsert(
        'INSERT INTO Test(name, value, num) VALUES("$name", "$value", "$num")');
    print(id1);
  }


  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController numController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: MaterialButton(
                  child: Text("Get Entries"),
                  color: Colors.blueAccent,
                  onPressed: (){
                    getEntries();
                    setState(() {
                    });
                  },
                ),
              ),
              Container(
              height: 500,
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: Text(entries[index]["id"].toString()),
                      title: Text(entries[index]["name"].toString()),
                      subtitle: Text(entries[index]["value"].toString()),
                      trailing: Text(entries[index]["num"].toString()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context){
              return Container(
                height: 350,
                child: Center(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_circle_rounded),
                          hintText: 'Name',
                       ),
                      ),
                      TextFormField(
                        controller: valueController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_circle_rounded),
                          hintText: 'Value',
                        ),
                      ),
                      TextFormField(
                        controller: numController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_circle_rounded),
                          hintText: 'Number',
                        ),
                      ),
                      SizedBox(height: 50,),
                      MaterialButton(
                        child: Text('Save'),
                        color: Colors.blue,
                        onPressed: () {
                           insertEntries(
                            nameController.text,
                             int.parse(valueController.text),
                             int.parse(numController.text),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                )
              );
            },
          );
        },
        child: Icon(Icons.add_circle),
      ),
    );
  }
}
