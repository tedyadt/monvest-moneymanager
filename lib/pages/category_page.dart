import 'package:flutter/material.dart';
import 'package:monvest/models/database.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  final AppDatabase database = AppDatabase();
  TextEditingController categoryNameController = TextEditingController();

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
            name: name, type: type, createdAt: now, updatedAt: now));
    print(row);
  }

  Future<List<Category>> getAllCategories() async {
    return await database.getAllCategoriesRepo(isExpense ? 2 : 1);
  }

  Future update(int categoryid, String newName) async {
    return await database.updateCategoriesRepo(categoryid, newName);
  }

  void openDialog(Category? category) {
    if (category != null) {
      categoryNameController.text = category.name;
    }
    showDialog(
      context: context,
      builder: (BuildContext) => AlertDialog(
        title: Text('Add Category'),
        content: TextField(
          controller: categoryNameController,
          decoration: InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (category == null) {
                insert(categoryNameController.text, isExpense ? 2 : 1);
              } else {
                update(category.id, categoryNameController.text);
              }

              Navigator.of(context, rootNavigator: true).pop('dialog');
              setState(() {});
              categoryNameController.clear();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: isExpense,
                onChanged: (bool value) {
                  setState(() {
                    isExpense = value;
                  });
                },
                inactiveTrackColor: Colors.green[200],
                inactiveThumbColor: Colors.green,
                activeColor: Colors.red,
              ),
              IconButton(
                  onPressed: () {
                    openDialog(null);
                  },
                  icon: Icon(Icons.add))
            ],
          ),
        ),
        FutureBuilder<List<Category>>(
          future: getAllCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasData) {
                if (snapshot.data!.length > 0) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          elevation: 6,
                          child: ListTile(
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    openDialog(snapshot.data![index]);
                                  },
                                ),
                                SizedBox(width: 6),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      database.deleteCategoriesRepo(
                                          snapshot.data![index].id);
                                      setState(() {});
                                    }),
                              ],
                            ),
                            title: Text(snapshot.data![index].name),
                            leading: Container(
                              child: (isExpense)
                                  ? Icon(Icons.upload, color: Colors.red)
                                  : Icon(Icons.download, color: Colors.blue),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No Data'));
                }
              }
              return Center(child: Text('No Data'));
            }
          },
        )
      ],
    ));
  }
}
