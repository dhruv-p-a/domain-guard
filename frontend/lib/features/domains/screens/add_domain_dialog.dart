import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/domain_provider.dart';

class AddDomainDialog extends StatefulWidget {
  const AddDomainDialog({super.key});

  @override
  State<AddDomainDialog> createState() => _AddDomainDialogState();
}

class _AddDomainDialogState extends State<AddDomainDialog> {
  final _domainController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _verificationMethod = 'DNS_TXT';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DomainProvider>();

    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.language_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Text('Add Domain for Monitoring'),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the website or API domain associated with your project. You will need to verify ownership via DNS TXT record.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _domainController,
                decoration: const InputDecoration(
                  labelText: 'Domain Name',
                  hintText: 'e.g. api.yourdomain.com',
                  prefixIcon: Icon(Icons.link_rounded, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a valid domain name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _verificationMethod,
                decoration: const InputDecoration(
                  labelText: 'Ownership Verification Method',
                  prefixIcon: Icon(Icons.verified_user_outlined, size: 20),
                ),
                items: const [
                  DropdownMenuItem(value: 'DNS_TXT', child: Text('DNS TXT Challenge Record')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _verificationMethod = val);
                },
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final navigator = Navigator.of(context);
                    final ok = await provider.addDomain(
                      _domainController.text.trim(),
                      method: _verificationMethod,
                    );
                    if (ok && mounted) {
                      navigator.pop();
                    }
                  }
                },
          child: provider.isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add Domain'),
        ),
      ],
    );
  }
}
