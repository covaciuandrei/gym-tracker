import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/constants/currencies.dart';
import 'package:gym_tracker/core/utils/app_date_formatter.dart';
import 'package:gym_tracker/core/utils/currency_formatter.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/presentation/controls/action_bottom_sheet.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';

class MembershipFormSheet extends StatefulWidget {
  const MembershipFormSheet({super.key, required this.title, required this.initial});

  final String title;
  final GymMembershipDraft initial;

  @override
  State<MembershipFormSheet> createState() => _MembershipFormSheetState();
}

class _MembershipFormSheetState extends State<MembershipFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _gymNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ValueNotifier<DateTime> _startDate = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<MembershipDuration> _duration = ValueNotifier<MembershipDuration>(MembershipDuration.oneMonth);
  final ValueNotifier<String> _currency = ValueNotifier<String>(fallbackCurrencyCode);

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _gymNameController.text = initial.gymName;
    _priceController.text = initial.priceMinor <= 0 ? '' : CurrencyFormatter.toInputValue(initial.priceMinor);
    _startDate.value = DateTime(initial.startDate.year, initial.startDate.month, initial.startDate.day);
    _duration.value = initial.duration;
    _currency.value = normalizeCurrencyCode(initial.currency);
  }

  @override
  void dispose() {
    _gymNameController.dispose();
    _priceController.dispose();
    _startDate.dispose();
    _duration.dispose();
    _currency.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final priceMinor = CurrencyFormatter.parseMinor(_priceController.text);
    if (priceMinor == null || priceMinor <= 0) return;

    Navigator.of(context).pop(
      GymMembershipDraft(
        gymName: _gymNameController.text.trim(),
        startDate: _startDate.value,
        duration: _duration.value,
        priceMinor: priceMinor,
        currency: _currency.value,
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate.value,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (selected != null) _startDate.value = selected;
  }

  String _durationLabel(AppLocalizations l10n, MembershipDuration duration) => switch (duration) {
    MembershipDuration.oneMonth => l10n.membershipDurationOneMonth,
    MembershipDuration.threeMonths => l10n.membershipDurationThreeMonths,
    MembershipDuration.sixMonths => l10n.membershipDurationSixMonths,
    MembershipDuration.twelveMonths => l10n.membershipDurationTwelveMonths,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ActionBottomSheet(
      title: widget.title,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _gymNameController,
              label: l10n.membershipGymName,
              hint: l10n.membershipGymNameHint,
              textInputAction: TextInputAction.next,
              validator: (value) => value == null || value.trim().isEmpty ? l10n.errorsFieldRequired : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _priceController,
              label: l10n.membershipPrice,
              hint: l10n.membershipPriceHint,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              validator: (value) {
                final priceMinor = CurrencyFormatter.parseMinor(value ?? '');
                if (value == null || value.trim().isEmpty) {
                  return l10n.errorsFieldRequired;
                }
                if (priceMinor == null) return l10n.errorsInvalidNumber;
                if (priceMinor <= 0) return l10n.errorsPositiveNumber;
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCurrencyField(l10n),
            const SizedBox(height: 16),
            _buildStartDateField(l10n),
            const SizedBox(height: 16),
            _buildDurationField(l10n),
            const SizedBox(height: 16),
            _buildValidityPreview(l10n),
          ],
        ),
      ),
      footer: GradientButton(label: l10n.calendarSave, isLoading: false, onTap: _save),
    );
  }

  Widget _buildCurrencyField(AppLocalizations l10n) {
    return ValueListenableBuilder<String>(
      valueListenable: _currency,
      builder: (_, currency, _) {
        return DropdownButtonFormField<String>(
          initialValue: currency,
          decoration: InputDecoration(labelText: l10n.membershipCurrency),
          items: supportedMembershipCurrencies
              .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) _currency.value = value;
          },
        );
      },
    );
  }

  Widget _buildStartDateField(AppLocalizations l10n) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _startDate,
      builder: (_, startDate, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickStartDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.membershipStartDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
            child: Text(AppDateFormatter.format(startDate)),
          ),
        );
      },
    );
  }

  Widget _buildDurationField(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<MembershipDuration>(
      valueListenable: _duration,
      builder: (_, selectedDuration, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.membershipDuration, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MembershipDuration.values
                  .map(
                    (duration) => ChoiceChip(
                      label: Text(_durationLabel(l10n, duration)),
                      selected: selectedDuration == duration,
                      onSelected: (_) => _duration.value = duration,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildValidityPreview(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([_startDate, _duration]),
      builder: (_, _) {
        final validUntil = _duration.value.validUntilFrom(_startDate.value);
        final formattedDate = AppDateFormatter.format(validUntil);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.event_available_outlined, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.membershipValidUntilValue(formattedDate),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
