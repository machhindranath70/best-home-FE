import 'package:flutter/material.dart';
import 'result_card.dart';

class ResultGrid extends StatefulWidget {
  final List<Map<String, dynamic>> results;

  const ResultGrid({super.key, required this.results});

  @override
  State<ResultGrid> createState() => _ResultGridState();
}

class _ResultGridState extends State<ResultGrid> {
  int currentPage = 0;
  final int itemsPerPage = 9;

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.results.length / itemsPerPage).ceil();
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(
      0,
      widget.results.length,
    );
    final currentItems = widget.results.sublist(startIndex, endIndex);

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          itemCount: currentItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) {
            return ResultCard(item: currentItems[index]);
          },
        ),

        // Pagination Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentPage > 0)
              ElevatedButton(
                onPressed: () {
                  setState(() => currentPage--);
                },
                child: const Text("⬅ Back"),
              ),
            const SizedBox(width: 16),
            Text("Page ${currentPage + 1} of $totalPages"),
            const SizedBox(width: 16),
            if (endIndex < widget.results.length)
              ElevatedButton(
                onPressed: () {
                  setState(() => currentPage++);
                },
                child: const Text("Next ➡"),
              ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
