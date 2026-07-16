import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/core/utils/file_picker_service.dart';
import 'package:reimburse_mate/models/expense_category.dart';
import 'package:reimburse_mate/models/payment_method.dart';
import 'package:reimburse_mate/features/ocr/application/ocr_notifier.dart';
import 'widgets/invoice_attachment_section.dart';
import 'widgets/payment_section.dart';
import 'widgets/details_form_section.dart';
import 'widgets/category_selector.dart';
import 'widgets/ocr_result_banner.dart';

class NewEntryScreen extends ConsumerStatefulWidget {
  const NewEntryScreen({super.key});

  @override
  ConsumerState<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends ConsumerState<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectCodeController = TextEditingController();
  final _particularsController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  PickedFileResult? _invoiceFile;
  PickedFileResult? _paymentFile;

  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'INR';
  ExpenseCategory _selectedCategory = ExpenseCategory.general;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;

  final FilePickerService _filePickerService = FilePickerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      setState(() {
        _selectedCurrency = settings.defaultCurrency;
      });
    });
  }

  @override
  void dispose() {
    _projectCodeController.dispose();
    _particularsController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment(bool isInvoice) async {
    final result = await showModalBottomSheet<PickedFileResult>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Capture with Camera'),
                onTap: () async {
                  final file = await _filePickerService.captureCameraPhoto();
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_rounded),
                title: const Text('Browse Files / Photos'),
                onTap: () async {
                  final file = await _filePickerService.pickImageOrPdf();
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        if (isInvoice) {
          _invoiceFile = result;
          if (result.type == CustomFileType.image) {
            // Auto run OCR for invoice images
            ref.read(ocrNotifierProvider.notifier).scanImage(result.path);
          }
        } else {
          _paymentFile = result;
          if (result.type == CustomFileType.image) {
            // Auto run OCR for payment proof images to try finding amount
            ref.read(ocrNotifierProvider.notifier).scanImage(result.path);
          }
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_invoiceFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice attachment is required!')),
      );
      return;
    }

    if (_projectCodeController.text.trim().isEmpty ||
        _particularsController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields (*).')),
      );
      return;
    }

    if (_selectedPaymentMethod.requiresPaymentProof && _paymentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment proof attachment is required for non-cash methods!')),
      );
      return;
    }

    final amountVal = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

    final success = await ref.read(entryNotifierProvider.notifier).saveClaim(
          date: _selectedDate,
          projectCode: _projectCodeController.text.trim().toUpperCase(),
          particulars: _particularsController.text.trim(),
          note: _notesController.text.trim(),
          category: _selectedCategory.name,
          amount: amountVal,
          currency: _selectedCurrency,
          status: 'yet_to_claim',
          invoicePath: _invoiceFile?.path,
          invoiceFileType: _invoiceFile?.type == CustomFileType.pdf ? 'pdf' : 'image',
          paymentPath: _paymentFile?.path,
          paymentFileType: _paymentFile?.type == CustomFileType.pdf ? 'pdf' : (_paymentFile != null ? 'image' : null),
          paymentMethod: _selectedPaymentMethod.dbKey,
        );

    if (success && mounted) {
      ref.read(claimsNotifierProvider.notifier).loadClaims();
      ref.read(ocrNotifierProvider.notifier).reset();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(entryNotifierProvider);
    final ocrState = ref.watch(ocrNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: isSaving ? null : _submitForm,
            child: isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 1. Invoice attachment
            InvoiceAttachmentSection(
              attachment: _invoiceFile,
              onPickPressed: () => _pickAttachment(true),
              onRemovePressed: () => setState(() => _invoiceFile = null),
            ),

            // OCR Banner if complete
            if (ocrState is OcrDone)
              OcrResultBanner(
                result: ocrState.result,
                onApply: () {
                  setState(() {
                    if (ocrState.result.amount != null) {
                      _amountController.text = ocrState.result.amount!.toStringAsFixed(2);
                    }
                    if (ocrState.result.currencyCode != null) {
                      _selectedCurrency = ocrState.result.currencyCode!;
                    }
                    if (ocrState.result.date != null) {
                      _selectedDate = ocrState.result.date!;
                    }
                    if (ocrState.result.vendor != null) {
                      _particularsController.text = ocrState.result.vendor!;
                    }
                  });
                  ref.read(ocrNotifierProvider.notifier).reset();
                },
                onDismiss: () => ref.read(ocrNotifierProvider.notifier).reset(),
              ),

            if (ocrState is OcrProcessing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),

            const SizedBox(height: 24),

            // 2. Category Selector
            const Text('Expense Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 24),

            // 3. Details Form
            DetailsFormSection(
              projectCodeController: _projectCodeController,
              particularsController: _particularsController,
              notesController: _notesController,
              amountController: _amountController,
              selectedCurrency: _selectedCurrency,
              onCurrencyChanged: (curr) => setState(() => _selectedCurrency = curr),
              selectedDate: _selectedDate,
              onSelectDate: _selectDate,
            ),
            const SizedBox(height: 24),

            // 4. Payment Proof
            PaymentSection(
              selectedMethod: _selectedPaymentMethod,
              onMethodChanged: (method) => setState(() => _selectedPaymentMethod = method),
              attachment: _paymentFile,
              onPickPressed: () => _pickAttachment(false),
              onRemovePressed: () => setState(() => _paymentFile = null),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
