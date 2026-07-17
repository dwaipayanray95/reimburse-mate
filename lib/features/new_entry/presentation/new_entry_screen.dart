import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/core/utils/file_picker_service.dart';
import 'package:reimburse_mate/core/widgets/glass_card.dart';
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  Future<void> _pickAttachment(bool isInvoice) async {
    await showModalBottomSheet<void>(
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
                  Navigator.pop(context);
                  await _runPick(() => _filePickerService.captureCameraPhoto(), isInvoice);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from Gallery (Photos / Google Photos)'),
                onTap: () async {
                  Navigator.pop(context);
                  await _runPick(() => _filePickerService.selectPhotoFromGallery(), isInvoice);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_rounded),
                title: const Text('Browse Documents / PDFs'),
                onTap: () async {
                  Navigator.pop(context);
                  await _runPick(() => _filePickerService.pickImageOrPdf(), isInvoice);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _runPick(Future<PickedFileResult?> Function() picker, bool isInvoice) async {
    PickedFileResult? result;
    try {
      result = await picker();
    } on AttachmentPickException catch (e) {
      _showError(e.message);
      return;
    } catch (e) {
      _showError('Something went wrong attaching that file.');
      return;
    }

    if (result == null || !mounted) return;

    setState(() {
      if (isInvoice) {
        _invoiceFile = result;
      } else {
        _paymentFile = result;
      }
    });

    if (result.type == CustomFileType.image) {
      ref.read(ocrNotifierProvider.notifier).scanImage(
            result.path,
            isInvoice ? OcrTarget.invoice : OcrTarget.payment,
          );
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
      _showError('Invoice attachment is required!');
      return;
    }

    if (_projectCodeController.text.trim().isEmpty || _particularsController.text.trim().isEmpty) {
      _showError('Please fill out all required fields (*).');
      return;
    }

    final amountText = _amountController.text.trim().replaceAll(',', '');
    final amountVal = double.tryParse(amountText);
    if (amountVal == null || amountVal <= 0) {
      _showError('Please enter a valid amount greater than zero.');
      return;
    }

    if (_selectedPaymentMethod.requiresPaymentProof && _paymentFile == null) {
      _showError('Payment proof attachment is required for non-cash methods!');
      return;
    }

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
    } else if (!success && mounted) {
      final error = ref.read(entryNotifierProvider).errorMessage;
      _showError(error ?? 'Could not save this claim. Please try again.');
      ref.read(entryNotifierProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(entryNotifierProvider);
    final isSaving = saveState.isSaving;
    final ocrState = ref.watch(ocrNotifierProvider);

    final theme = Theme.of(context);

    return Scaffold(
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(Icons.close_rounded, size: 18),
                        ),
                      ),
                    ),
                    const Text(
                      'New Entry',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    Material(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: isSaving ? null : _submitForm,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          child: isSaving
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  'Save',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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

                    if (ocrState is OcrError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 16, color: theme.colorScheme.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Couldn't read this receipt automatically — you can still fill it in manually.",
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref.read(ocrNotifierProvider.notifier).reset(),
                              child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
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
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DetailsFormSection(
                        projectCodeController: _projectCodeController,
                        particularsController: _particularsController,
                        notesController: _notesController,
                        amountController: _amountController,
                        selectedCurrency: _selectedCurrency,
                        onCurrencyChanged: (curr) => setState(() => _selectedCurrency = curr),
                        selectedDate: _selectedDate,
                        onSelectDate: _selectDate,
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
