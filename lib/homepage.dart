import 'package:denomination/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:number_to_words_english/number_to_words_english.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // List of denominations
  final Map<int, TextEditingController> controllers = {};
  final List<int> denominations = [2000, 500, 200, 100, 50, 20, 10, 5, 2, 1];
  final Map<int, int> counts = {};
  int totalAmount = 0;
  bool isExpanded = false;
    final storage = GetStorage();
    String amountInWords = '';
    



  @override
  void initState() {
    super.initState();
    for (var denom in denominations) {
      counts[denom] = 0;
      controllers[denom] = TextEditingController();
    }
  }

  void updateTotalAmount() {
    int total = 0;
    counts.forEach((denomination, count) {
      total += denomination * count!;
    });
    setState(() {
      totalAmount = total;
      amountInWords = capitalizeFirstLetter(NumberToWordsEnglish.convert(totalAmount));
    });
  }

  String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}
void saveDataToStorage() {
  showDialog(
    context: context,
    builder: (context) {
      String remarks = "";
      String selectedOption = "General"; // Default dropdown value
      return AlertDialog(
         backgroundColor:  const Color.fromARGB(255, 17, 23, 27),
        title: const Center(child: Text("Save Data", style: TextStyle(color: Colors.white),)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            DropdownButtonFormField<String>(
              dropdownColor: Colors.black,
              value: selectedOption,
              items: ["General", "Income", "Expense"]
                  .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: TextStyle(color: Colors.white),),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value != null) {
                  selectedOption = value;
                }
              },
            ),
            const SizedBox(height: 16),
             TextField(
              decoration: const InputDecoration(
                labelText: "Fill your remark(if any)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                remarks = value;
              },
            ),
            
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final List<Map<String, dynamic>> storedData =
                    storage.read<List<dynamic>>('denomination_history')?.cast<Map<String, dynamic>>() ?? [];
                final newData = {
                  'counts': counts,
                  'totalAmount': totalAmount,
                  'remarks': remarks,
                  'category': selectedOption,
                  'timestamp': DateTime.now().toIso8601String(),
                };
                storedData.add(newData);
                storage.write('denomination_history', storedData);
                print("Data saved successfully: $newData");
                setState(() {
                  counts.updateAll((key, value) => 0);
                  controllers.forEach((key, controller) => controller.clear());
                  totalAmount = 0;
                });
                Navigator.pop(context); // Close the dialog
              } catch (e) {
                print("Error saving data: $e");
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/images/currency_banner.jpg"),fit: BoxFit.cover)),
                child:  Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding:  const EdgeInsets.all(8.0),
                    child: totalAmount>0 ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       const Text("Total Amount", style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500)),
                        Text("₹ $totalAmount", style:const TextStyle(fontSize: 18,fontWeight: FontWeight.w500)),
                        Text("$amountInWords only/-", style:const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                      ],
                    ):const Text("Denomination", style: TextStyle(fontSize: 28),),
                  )),
              ),
              Positioned(
                top: 25,
                right: 10,
                child: IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> History()));

                }, icon: const Icon(Icons.more_vert, color: Colors.white,)))
            ],
          ),
        
          Expanded(
            child: ListView.builder(
              itemCount: denominations.length,
              itemBuilder: (context, index) {
                int denomination = denominations[index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "₹$denomination",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("x", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: controllers[denomination],
                          keyboardType: TextInputType.number,
                         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              counts[denomination] =
                                  int.tryParse(value) ?? 0;
                              updateTotalAmount();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex:2,
                        child: Text(
                          "= ₹${counts[denomination]! * denomination}",
                          style:const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
       floatingActionButton: totalAmount>0?Stack(
        children: [
          if (isExpanded)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                tooltip: "Clear",
                heroTag: "clear",
                onPressed: (){
                 setState(() {
                    counts.updateAll((key, value) => 0);
                  controllers.forEach((key, controller) => controller.clear());
                  totalAmount = 0;
                 });
                },
                backgroundColor: Colors.grey[800],
                child:const Icon(Icons.restart_alt,color: Colors.white,),
              ),
            ),
          if (isExpanded)
            Positioned(
              bottom: 140,
              right: 16,
              child: FloatingActionButton(
                   tooltip: "Save",
                heroTag: "save",
                onPressed: saveDataToStorage,
                backgroundColor: Colors.grey[800],
                child:const Icon(Icons.file_download,color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded; // Toggle visibility
                });
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.bolt, color: Colors.white,),
            ),
          ),
        ],
      ): null
    );
  }
}