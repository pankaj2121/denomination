import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class History extends StatelessWidget {
  final storage = GetStorage();

  History({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve saved data
    final List<Map<String, dynamic>> historyData = storage
            .read<List<dynamic>>('denomination_history')
            ?.cast<Map<String, dynamic>>() ??
        [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          "History",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: historyData.isEmpty
          ? const Center(
              child: Text(
                "No history available.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
  itemCount: historyData.length,
  itemBuilder: (context, index) {
    final entry = historyData[index];
    final counts = entry['counts'] as Map<dynamic, dynamic>;
    final totalAmount = entry['totalAmount'] as int;
    final remarks = entry['remarks'] as String;
    final category = entry['category'] as String;
    final timestamp = entry['timestamp'] as String;

    // Format timestamp
    final dateTime = DateTime.parse(timestamp);
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Dismissible(
      key: Key(timestamp), // Unique key for each item
      direction: DismissDirection.startToEnd, // Swipe left-to-right or right-to-left
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        // Show a confirmation dialog before deleting
        return await showDialog(
          
          context: context,
          builder: (context) => AlertDialog(
             backgroundColor:  const Color.fromARGB(255, 17, 23, 27),
            title: const Text('Confirm Delete', style: TextStyle(color: Colors.white),),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Handle deletion
        historyData.removeAt(index);
        storage.write('denomination_history', historyData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted')),
        );
      },
      child: GestureDetector(
        onTap: () {},
        child: Card(
          color: const Color.fromARGB(255, 17, 23, 27),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontSize: 10),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "₹ $totalAmount",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: category == "Income"
                              ? Colors.green
                              : category == "Expense"
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color.fromARGB(255, 156, 179, 198),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color.fromARGB(255, 156, 179, 198),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Text(
                  "Remarks: $remarks",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 156, 179, 198),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
)

    );
  }
}
