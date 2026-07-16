import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';

class DetailsFormSection extends StatelessWidget {
  final TextEditingController projectCodeController;
  final TextEditingController particularsController;
  final TextEditingController notesController;
  final TextEditingController amountController;
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;
  final DateTime selectedDate;
  final VoidCallback onSelectDate;

  const DetailsFormSection({
    super.key,
    required this.projectCodeController,
    required this.particularsController,
    required this.notesController,
    required this.amountController,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reimbursement Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Date selection
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Expense Date', style: TextStyle(fontWeight: FontWeight.w500)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          onTap: onSelectDate,
        ),
        const Divider(height: 1),

        // Project Code
        TextFormField(
          controller: projectCodeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Project Code *',
            hintText: 'e.g. ACC-2025-07',
            border: InputBorder.none,
          ),
        ),
        const Divider(height: 1),

        // Particulars
        TextFormField(
          controller: particularsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Particulars *',
            hintText: 'e.g. Taxi to airport, lunch with client',
            border: InputBorder.none,
          ),
        ),
        const Divider(height: 1),

        // Notes
        TextFormField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Additional Notes',
            hintText: 'e.g. Client name, meeting purpose',
            border: InputBorder.none,
          ),
        ),
        const Divider(height: 1),

        // Amount & Currency Row
        Row(
          children: [
            InkWell(
              onTap: () {
                showCurrencyPicker(
                  context: context,
                  showFlag: true,
                  showCurrencyName: true,
                  showCurrencyCode: true,
                  onSelect: (Currency currency) {
                    onCurrencyChanged(currency.code);
                  },
                );
              },
              child: Row(
                children: [
                  Text(
                    selectedCurrency,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  hintText: '0.00',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
