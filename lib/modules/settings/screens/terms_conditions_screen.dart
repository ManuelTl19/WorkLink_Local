import 'dart:async';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/helpers/services/legal_documents_service.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _loading = true;
  bool _openingPdf = false;
  String? _error;
  LegalDocumentMetadata? _metadata;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final metadata =
          await LegalDocumentsService.fetchTermsAndConditionsMetadata();
      if (!mounted) return;
      setState(() {
        _metadata = metadata;
        _loading = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            MultiLanguages.of(context)?.translate('timeout_error') ??
            'Tiempo de espera agotado. Verifica tu conexion e intentalo de nuevo.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openTerms() async {
    final metadata = _metadata;
    if (metadata == null || _openingPdf) return;

    setState(() => _openingPdf = true);
    try {
      await LegalDocumentsService.openTermsAndConditionsPdf(metadata);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _openingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: RefreshIndicator(
        onRefresh: _loadMetadata,
        color: Style.getPrimaryColor(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Style.getBackgroundColor(),
              surfaceTintColor: Style.transparent,
              elevation: 0,
              titleSpacing: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Style.getTextColor(),
                ),
              ),
              title: Text(
                MultiLanguages.of(context)?.translate('terms_conditions') ??
                    'Terminos y condiciones',
                style: Style.getHeaderTwo(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  20.h,
                ),
                child: _content(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: 220.h,
        child: Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Style.getCardColor(),
          borderRadius: Style.getCircularBorderRadius(22),
          border: Border.all(
            color: Style.getErrorColor().withValues(alpha: .25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MultiLanguages.of(context)?.translate('error') ?? 'Error',
              style: Style.getHeaderThree(
                color: Style.getErrorColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _error ?? '-',
              style: Style.getTextStyle(color: Style.getObscureTextColor()),
            ),
            SizedBox(height: 14.h),
            CustomWidgets.button(
              onTap: _loadMetadata,
              color: Style.getPrimaryColor(),
              child: Text(
                MultiLanguages.of(context)?.translate('retry') ?? 'Reintentar',
                style: Style.getHeaderThree(
                  color: Style.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final metadata = _metadata;
    if (metadata == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: Style.getCircularBorderRadius(22),
        border: Border.all(
          color: Style.getBorderColor().withValues(alpha: .12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MultiLanguages.of(context)?.translate('terms_conditions') ??
                'Terminos y condiciones',
            style: Style.getHeaderTwo(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          _metaRow(
            label:
                MultiLanguages.of(context)?.translate('terms_updated_at') ??
                'Ultima actualizacion',
            value: LegalDocumentsService.formatUpdatedAt(metadata.updatedAt),
          ),
          SizedBox(height: 8.h),
          _metaRow(
            label:
                MultiLanguages.of(context)?.translate('terms_file_size') ??
                'Tamano del archivo',
            value: LegalDocumentsService.formatFileSize(metadata.fileSize),
          ),
          SizedBox(height: 16.h),
          CustomWidgets.button(
            onTap: _openingPdf ? () {} : _openTerms,
            color: Style.getPrimaryColor(),
            child: _openingPdf
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Style.white,
                    ),
                  )
                : Text(
                    MultiLanguages.of(context)?.translate('view_terms') ??
                        'Ver terminos',
                    style: Style.getHeaderThree(
                      color: Style.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Style.getTextStyle(
              color: Style.getObscureTextColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: Style.getTextStyle(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
