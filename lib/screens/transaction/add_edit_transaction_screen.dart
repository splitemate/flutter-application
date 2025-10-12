import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/current_user.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final CurrentUser me;
  final bool isEdit;
  final String? transactionId;
  final double? initialAmount;
  final String? initialDescription;
  final DateTime? initialDate;
  final List<String>? initialImages;

  const AddEditTransactionScreen({
    super.key,
    required this.me,
    required this.isEdit,
    this.transactionId,
    this.initialAmount,
    this.initialDescription,
    this.initialDate,
    this.initialImages,
  });

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<String> _uploadedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.isEdit) {
      _amountController.text = widget.initialAmount?.toString() ?? '';
      _descriptionController.text = widget.initialDescription ?? '';
      _selectedDate = widget.initialDate ?? DateTime.now();
      _uploadedImages = widget.initialImages ?? [];
    }
    _dateController.text = _formatDate(_selectedDate);
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kGradColors[0],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kWhiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEdit 
              ? 'Edit Transaction' 
              : 'Add Transaction',
          style: TextStyle(
            color: kWhiteColor,
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT-Walsheim-Pro',
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Input Field
                    _buildInputField(
                      label: 'Amount',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      prefix: '₹ ',
                      valueColor: kGreenColor,
                    ),
                    
                    SizedBox(height: size.height * 0.03),
                    
                    // Category Input Field
                    _buildInputField(
                      label: 'Description',
                      controller: _descriptionController,
                      hintText: 'Enter transaction details',
                    ),
                    
                    SizedBox(height: size.height * 0.03),
                    
                    // Date Input Field
                    _buildDateField(size),
                    
                    SizedBox(height: size.height * 0.03),
                    
                    // Images Section
                    _buildImagesSection(size),
                  ],
                ),
              ),
            ),
            
            // Save Button
            Container(
              padding: EdgeInsets.all(size.width * 0.06),
              child: Container(
                width: double.infinity,
                height: size.height * 0.06,
                decoration: BoxDecoration(
                  color: kGreenColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  child: _isLoading
                      ? SizedBox(
                          width: size.width * 0.05,
                          height: size.width * 0.05,
                          child: CircularProgressIndicator(
                            color: kWhiteColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: kWhiteColor,
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GT-Walsheim-Pro',
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hintText,
    String? prefix,
    Color? valueColor,
  }) {
    Size size = MediaQuery.of(context).size;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: kBlackColor,
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT-Walsheim-Pro',
          ),
        ),
        SizedBox(height: size.height * 0.01),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: valueColor ?? kBlackColor,
            fontSize: size.width * 0.04,
            fontFamily: 'GT-Walsheim-Pro',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefix,
            hintStyle: TextStyle(
              color: kGreyColor.withValues(alpha: 0.5),
              fontSize: size.width * 0.04,
              fontFamily: 'GT-Walsheim-Pro',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kGreyColor.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kGreyColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kGradColors[0]),
            ),
            contentPadding: EdgeInsets.all(size.width * 0.04),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (label == 'Amount' && double.tryParse(value) == null) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            color: kBlackColor,
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT-Walsheim-Pro',
          ),
        ),
        SizedBox(height: size.height * 0.01),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          style: TextStyle(
            color: kBlackColor,
            fontSize: size.width * 0.04,
            fontFamily: 'GT-Walsheim-Pro',
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kGreyColor.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kGreyColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kGradColors[0]),
            ),
            contentPadding: EdgeInsets.all(size.width * 0.04),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today, color: kGreyColor),
              onPressed: _selectDate,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images',
          style: TextStyle(
            color: kBlackColor,
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT-Walsheim-Pro',
          ),
        ),
        SizedBox(height: size.height * 0.01),
        
        // Upload Area
        Container(
          width: double.infinity,
          height: size.height * 0.15,
          decoration: BoxDecoration(
            border: Border.all(color: kGreyColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _pickImage,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: size.width * 0.08,
                  color: kGreyColor,
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Click to add images',
                  style: TextStyle(
                    color: kGreyColor,
                    fontSize: size.width * 0.035,
                    fontFamily: 'GT-Walsheim-Pro',
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Uploaded Images
        if (_uploadedImages.isNotEmpty) ...[
          SizedBox(height: size.height * 0.02),
          Row(
            children: _uploadedImages.map((imagePath) {
              return Container(
                margin: EdgeInsets.only(right: size.width * 0.03),
                child: Stack(
                  children: [
                    Container(
                      width: size.width * 0.2,
                      height: size.width * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(imagePath),
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: kRedColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: kWhiteColor,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _pickImage() {
    // TODO: Implement image picker functionality
    // For now, add demo images
    setState(() {
      _uploadedImages.add('assets/images/lion.jpg');
    });
  }

  void _removeImage(String imagePath) {
    setState(() {
      _uploadedImages.remove(imagePath);
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      // TODO: Implement save functionality
      await Future.delayed(Duration(seconds: 1)); // Simulate save

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction saved successfully!'),
            backgroundColor: kGreenColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving transaction: ${e.toString()}'),
            backgroundColor: kRedColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
} 