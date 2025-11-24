import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import 'package:lottie/lottie.dart';

const Color primaryDarkColor = Color(0xFF0D0D12);
const Color accentNeon = Color(0xFF00FFFF);
const Color secondaryAccent = Color(0xFF4A64FE);
const Color cardDarkColor = Color(0xFF1B1B25);
const Color textLightColor = Colors.white;

class JobApplicationModal extends StatefulWidget {
  final Job job;
  final Map<String, dynamic> userData;
  final String userId;

  const JobApplicationModal({
    super.key,
    required this.job,
    required this.userData,
    required this.userId,
  });

  @override
  State<JobApplicationModal> createState() => _JobApplicationModalState();
}

class _JobApplicationModalState extends State<JobApplicationModal> {
  late TextEditingController _coverLetterController;
  late TextEditingController _experienceController;
  late TextEditingController _notesController;

  bool _isSubmitting = false;
  String? _selectedExperience;
  final List<String> _experienceOptions = [
    'Fresher',
    '1-2 years',
    '2-5 years',
    '5-10 years',
    '10+ years',
  ];

  @override
  void initState() {
    super.initState();
    _coverLetterController = TextEditingController();
    _experienceController = TextEditingController();
    _notesController = TextEditingController();

    // Pre-fill experience if available in user data
    final rawExp = widget.userData['experience'];
    if (rawExp != null) {
      final expStr = rawExp.toString().trim();

      // If it exactly matches one of our options, use it
      if (_experienceOptions.contains(expStr)) {
        _selectedExperience = expStr;
      } else {
        // Try to map common formats (like "1 year", "3 yrs", "3")
        final match = RegExp(r"(\\d+)").firstMatch(expStr);
        if (match != null) {
          final yrs = int.tryParse(match.group(1) ?? '');
          if (yrs != null) {
            if (yrs == 0)
              _selectedExperience = 'Fresher';
            else if (yrs == 1)
              _selectedExperience = '1-2 years';
            else if (yrs >= 2 && yrs <= 4)
              _selectedExperience = '2-5 years';
            else if (yrs >= 5 && yrs <= 9)
              _selectedExperience = '5-10 years';
            else
              _selectedExperience = '10+ years';
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _experienceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (_selectedExperience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your experience level')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await JobService.submitJobApplication(
        userId: widget.userId,
        jobId: widget.job.id,
        coverLetter: _coverLetterController.text.trim(),
        experience: _selectedExperience!,
        additionalNotes: _notesController.text.trim(),
        name: widget.userData['name'] ?? '',
        email: widget.userData['email'] ?? '',
        phone: widget.userData['phone'] ?? '',
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (response == true) {
        showSuccessPopup(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error submitting: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        constraints: const BoxConstraints(
          minHeight: 500, // small screens ke liye
          maxHeight: 900, // very large screens control
        ),
        decoration: const BoxDecoration(
          color: cardDarkColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight, // full stretch
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCompanyInfoSection(),
                            const SizedBox(height: 28),
                            _buildApplicationFormSection(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // bottom button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryAccent,
                    disabledBackgroundColor: secondaryAccent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  textLightColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Submitting...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textLightColor,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textLightColor,
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

  Widget _buildCompanyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Job Title
        Text(
          widget.job.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textLightColor,
          ),
        ),
        const SizedBox(height: 8),

        // Company name with logo
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: accentNeon,
              child: Text(
                widget.job.logoText,
                style: const TextStyle(
                  color: primaryDarkColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.company,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textLightColor,
                    ),
                  ),
                  Text(
                    widget.job.location,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Company Details Grid
        Container(
          decoration: BoxDecoration(
            color: primaryDarkColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _companyDetailRow(
                Icons.currency_rupee,
                'Salary',
                widget.job.salary,
              ),
              const SizedBox(height: 12),
              _companyDetailRow(
                Icons.work_rounded,
                'Job Type',
                widget.job.type,
              ),
              const SizedBox(height: 12),
              _companyDetailRow(
                Icons.school_rounded,
                'Experience Required',
                widget.job.experience,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Description or about company (if available)
        Text(
          'About This Role',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryDarkColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            'Join ${widget.job.company} as a ${widget.job.title}. This is an exciting opportunity to grow your career with a leading organization.',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _companyDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accentNeon),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: textLightColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Application',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textLightColor,
          ),
        ),
        const SizedBox(height: 16),

        // Pre-filled: Name (Read-only)
        _buildInfoField(
          label: 'Full Name',
          value: widget.userData['name'] ?? 'N/A',
          isReadOnly: true,
        ),
        const SizedBox(height: 14),

        // Pre-filled: Email (Read-only)
        _buildInfoField(
          label: 'Email',
          value: widget.userData['email'] ?? 'N/A',
          isReadOnly: true,
        ),
        const SizedBox(height: 14),

        // Pre-filled: Phone (Read-only)
        _buildInfoField(
          label: 'Phone Number',
          value: widget.userData['phone'] ?? 'N/A',
          isReadOnly: true,
        ),
        const SizedBox(height: 14),

        // Experience Level (Dropdown)
        Text(
          'Experience Level',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: primaryDarkColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _selectedExperience != null
                  ? accentNeon.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox.shrink(),
            value: _experienceOptions.contains(_selectedExperience)
                ? _selectedExperience
                : null,
            hint: Text(
              'Select your experience',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            dropdownColor: cardDarkColor,
            items: _experienceOptions.map((exp) {
              return DropdownMenuItem(
                value: exp,
                child: Text(exp, style: const TextStyle(color: textLightColor)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedExperience = value);
            },
          ),
        ),
        const SizedBox(height: 18),

        // Cover Letter
        Text(
          'Cover Letter (Optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _coverLetterController,
          maxLines: 4,
          style: const TextStyle(color: textLightColor),
          decoration: InputDecoration(
            hintText:
                'Tell the company why you\'re interested in this position...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: primaryDarkColor.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: accentNeon, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 18),

        // Additional Notes
        Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: textLightColor),
          decoration: InputDecoration(
            hintText:
                'Any additional information you\'d like to share with the employer...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: primaryDarkColor.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: accentNeon, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 8),

        // Info text
        Text(
          'Your profile information (name, email, phone) will be sent automatically.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: primaryDarkColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: textLightColor),
          ),
        ),
      ],
    );
  }

  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardDarkColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentNeon.withOpacity(0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentNeon.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/success.json',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Application Submitted",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: textLightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // close popup
      Navigator.pop(context, true); // close bottom sheet
    });
  }
}
