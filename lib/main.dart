import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:to_do_list/ItemDBHelper.dart';
import 'package:pie_chart/pie_chart.dart';

void main() {
  runApp(myApp());
}

class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ToDoListPage(),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {

  Icon icn = Icon(Icons.nightlight_round_rounded);

  bool dark = false;

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> checkedItems = [];

  bool isChecked = false;

  TextEditingController titleCtrl = TextEditingController();

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItemsFromDB();
    getCountValue();
  }

  void getItemsFromDB() async {
    items = await ItemDBHelper().fetchItems();
    setState(() {});
  }

  void getCountValue() async{
    checkedItems = await ItemDBHelper().getCount();
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    getItemsFromDB();
    getCountValue();

    Map<String, double> dataMap = {
      "Complete": checkedItems.length.toDouble(),
      "Pending": (items.length-checkedItems.length).toDouble(),
    };

    final legendLabels = <String, String>{
      "Complete": "${checkedItems.length}",
      "Pending": "${(items.length-checkedItems.length)}",
    };

    final colorList = <Color>[
      const Color(0xff0984e3),//complete
      const Color(0xfffdcb6e),//pending
      const Color(0xfffd79a8),
      const Color(0xffe17055),
      const Color(0xff6c5ce7),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(flex: 9, child: Text("To Do List")),
            Expanded(
              flex:1,
              child: PopupMenuButton(
                  icon: const Icon(
                    Icons.menu,
                    size: 30,
                    color: Colors.white,
                  ),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Delete All Tasks"),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text("Check Stats"),
                      ),
                    ];
                  },
                  onSelected: (value) async {
                    if (value == 0) {
                      // set up the buttons
                      Widget cancelButton = TextButton(
                        child: const Text("Cancel", style: TextStyle(color: Colors.blue),),
                        onPressed: () {
                          //cancel dialog
                          Navigator.pop(context);
                        },
                      );
                      Widget deleteButton = TextButton(
                        child: const Text("Delete All"),
                        onPressed: () async {
                          //delete all notes
                          await ItemDBHelper().deleteAllItems();
                          Fluttertoast.showToast(
                              msg: "All Tasks Deleted Successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey.shade200,
                              textColor: Colors.black,
                              fontSize: 16.0);
                          Navigator.pop(context);
                          setState(() {});
                        },
                      );

                      AlertDialog alert = AlertDialog(
                        title: const Text("Do you want to delete all tasks ?"),
                        actions: [
                          cancelButton,
                          deleteButton,
                        ],
                      );

                      // show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );

                      setState(() {});
                    }
                    else if (value == 1) {

                      AlertDialog alert = AlertDialog(
                        title: const Center(child: Text("Statistics")),
                        content: SizedBox(
                          height: 100,
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PieChart(
                                dataMap: dataMap,
                                animationDuration: const Duration(milliseconds: 800),
                                chartLegendSpacing: 32,
                                chartRadius: MediaQuery.of(context).size.width,
                                colorList: colorList,
                                initialAngleInDegree: 0,
                                chartType: ChartType.ring,
                                ringStrokeWidth: 32,
                                legendOptions: LegendOptions(
                                  legendLabels: legendLabels,
                                  showLegendsInRow: false,
                                  legendPosition: LegendPosition.right,
                                  showLegends: true,
                                  legendShape: BoxShape.circle,
                                  legendTextStyle: const TextStyle(

                                  ),
                                ),
                                chartValuesOptions: const ChartValuesOptions(
                                  showChartValueBackground: true,
                                  showChartValues: true,
                                  showChartValuesInPercentage: false,
                                  showChartValuesOutside: false,
                                  decimalPlaces: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      // show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );

                      setState(() {});

                    }
                  }),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Center(child: Text("${items.length} ${word()}", style: TextStyle(color: Colors.grey.shade600),)),
              const SizedBox(height: 10,),
              line(),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          Container(
                            color: items[index]['item_check'] == 0
                                ? Colors.white
                                : Colors.red.shade50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 1.5,
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            getColor),
                                    value: items[index]['item_check'] == 0
                                        ? false
                                        : true,
                                    onChanged: (bool? value) {
                                      int checkVal;
                                      value! ? checkVal = 1 : checkVal = 0;
                                      updateCheck(items[index]['item_id'], checkVal);
                                      getCountValue();
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Expanded(
                                    flex: 8,
                                    child: Text(
                                      "${items[index]['item_name']}",
                                      style: TextStyle(
                                          decoration:
                                              (items[index]['item_check']) == 0
                                                  ? null
                                                  : TextDecoration.lineThrough,
                                          fontSize: 17),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: InkWell(
                                      onTap: () {
                                        //delete this to do
                                        // set up the buttons
                                        Widget cancelButton = TextButton(
                                          child: const Text("Cancel", style: TextStyle(color: Colors.blue),),
                                          onPressed: () {
                                            //cancel dialog
                                            Navigator.pop(context);
                                          },
                                        );
                                        Widget deleteButton = TextButton(
                                            child: const Text("Delete"),
                                            onPressed: () async {
                                              //delete note
                                              await ItemDBHelper().deleteItem(
                                                  '${items[index]['item_id']}');
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "${items[index]['item_name']} Deleted Successfully",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  textColor: Colors.black,
                                                  fontSize: 16.0);
                                              Navigator.pop(context);
                                              setState(() {});
                                            });

                                        AlertDialog alert = AlertDialog(
                                          title: const Text(
                                              "Do you want to delete this to-do task ?"),
                                          actions: [
                                            cancelButton,
                                            deleteButton,
                                          ],
                                        );

                                        // show the dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.grey,
                                      )),
                                ),
                              ],
                            ),
                          ),
                          line(),
                        ],
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () {
            //open dialog box
            Widget cancelButton = TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.blue),),
              onPressed: () {
                Navigator.pop(context);
              },
            );
            Widget createBtn = TextButton(
              child: const Text("Create To-Do"),
              onPressed: () {
                //add item to db
                if (titleCtrl.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Title is mandatory",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey.shade200,
                      textColor: Colors.black,
                      fontSize: 16.0);
                } else {
                  String itemName = titleCtrl.text.toString();
                  int checkVal = 0;
                  insertItem(iName: itemName, iCheck: checkVal);
                  Navigator.pop(context);
                  titleCtrl.clear();
                }
              },
            );

            AlertDialog alert = AlertDialog(
              title: const Text("To Do Title"),
              content: SizedBox(
                width: 100,
                height: 50,
                child: Column(
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        hintText: "Enter Title",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                cancelButton,
                createBtn,
              ],
            );

            // show the dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );

            setState(() {});
          },
          tooltip: "Add To Do",
          child: const Icon(
            Icons.add,
            size: 31,
          ),
        ),
      ),
    );
  }

  Widget line() {
    return Container(
      width: double.infinity,
      height: 1,
      color: Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 7),
    );
  }

  void insertItem({required String iName, required int iCheck}) async {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    //insert note
    await ItemDBHelper()
        .addItem(id: timeStamp.toString(), name: iName, checkVal: iCheck);
    items = await ItemDBHelper().fetchItems();
    setState(() {});
  }

  void updateCheck(String id, int check) async {
    await ItemDBHelper().updateCheckOfItem(id, check);
    items = await ItemDBHelper().fetchItems();
    setState(() {});
  }

  String word(){
    int count = items.length;
    String word;
    if(count>1){
      word = "Tasks";
    }else{
      word = "Task";
    }
    return word;
  }

}