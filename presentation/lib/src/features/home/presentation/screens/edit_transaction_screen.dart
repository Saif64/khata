import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_event.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionEntity transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TransactionType _transactionType;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _transactionType = widget.transaction.type;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      HapticFeedback.lightImpact();

      final updatedTransaction = TransactionEntity(
        id: widget.transaction.id,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        type: _transactionType,
        date: widget.transaction.date, // Keep the original date
      );

      context.read<HomeBloc>().add(EditTransaction(updatedTransaction));

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction updated successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _delete() async {
    setState(() {
      _isLoading = true;
    });

    HapticFeedback.heavyImpact();

    context.read<HomeBloc>().add(DeleteTransaction(widget.transaction.id));

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction deleted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSale = _transactionType == TransactionType.sale;
    final primaryColor = isSale ? colorScheme.primary : colorScheme.error;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Transaction',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
            onPressed: _delete,
          )
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        _buildAmountInput(theme, colorScheme, primaryColor),
                        const SizedBox(height: 24),
                        _buildDescriptionInput(theme, colorScheme),
                        const SizedBox(height: 32),
                        _buildSubmitButton(theme, primaryColor, isSale),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(
      ThemeData theme, ColorScheme colorScheme, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'Enter amount',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(
                FontAwesomeIcons.dollarSign,
                color: primaryColor,
                size: 16,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: colorScheme.surface,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value) <= 0) {
              return 'Amount must be greater than zero';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionInput(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'What is this for?',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(
                FontAwesomeIcons.noteSticky,
                color: colorScheme.primary,
                size: 16,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: colorScheme.surface,
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            if (value.trim().length < 3) {
              return 'Description must be at least 3 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, Color primaryColor, bool isSale) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text('Update Transaction'),
      ),
    );
  }
}
