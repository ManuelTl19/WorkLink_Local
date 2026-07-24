import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/reviews/models/review_model.dart';
import 'package:worklink_local/modules/reviews/screens/review_form_screen.dart';
import 'package:worklink_local/modules/reviews/services/reviews_service.dart';
import 'package:worklink_local/utils/utils.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _loading = true;
  bool _submitting = false;
  List<ReviewModel> _reviews = const [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    try {
      final reviews = await ReviewsService.listMyReviews();
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Calificaciones',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _openReviewForm(ReviewModel review) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await Navigator.of(context).push(
        Transitions.slideUpTransition(
          ReviewFormScreen(
            contractId: review.contractId ?? 0,
            reviewedUserId: review.reviewedUserId,
            reviewedUserName: review.reviewedUserName,
            reviewedUserType: review.reviewedUserType,
            reviewId: review.id,
            initialReview: review,
          ),
        ),
      );

      if (result != null && mounted) {
        await _loadReviews();
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _startNewReview() async {
    if (_submitting) return;
    Dialogs.showSimpleDialog(
      context,
      title: 'Calificaciones',
      message:
          'La creación de nuevas reseñas se abre desde un contrato finalizado en solicitudes contratadas.',
      color: Style.getPrimaryColor(),
      icon: Icons.star_rounded,
    );
  }

  Future<void> _deleteReview(ReviewModel review) async {
    if (_submitting) return;

    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title: 'Eliminar reseña',
      message: '¿Quieres eliminar esta reseña?',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      confirmColor: Style.getErrorColor(),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await ReviewsService.deleteReview(review.id);
      if (!mounted) return;
      await _loadReviews();
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Calificaciones',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((item) => item.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        surfaceTintColor: Style.transparent,
        title: Text(
          'Mis calificaciones',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadReviews,
            icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewReview,
        backgroundColor: Style.getPrimaryColor(),
        foregroundColor: Style.white,
        icon: const Icon(Icons.star_rounded),
        label: const Text('Nueva reseña'),
      ),
      body: _loading
          ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: ListView(
                padding: EdgeInsets.all(Style.horizontalPadding.w),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Style.getPrimaryColor(),
                          Style.getPrimaryColor().withValues(alpha: .82),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _statCard('Total', _reviews.length.toString(), Icons.rate_review_rounded),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _statCard('Promedio', _averageRating.toStringAsFixed(1), Icons.star_rounded),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _statCard('Comentadas', _reviews.where((item) => item.hasComment).length.toString(), Icons.chat_bubble_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (_reviews.isEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 34.h, horizontal: 18.w),
                      decoration: BoxDecoration(
                        color: Style.getCardColor(),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.rate_review_outlined, size: 52.w, color: Style.getObscureTextColor().withValues(alpha: .5)),
                          SizedBox(height: 12.h),
                          Text(
                            'Todavía no tienes calificaciones registradas.',
                            textAlign: TextAlign.center,
                            style: Style.getTextStyle(
                              color: Style.getObscureTextColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._reviews.map(
                      (review) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ReviewCard(
                          review: review,
                          onEdit: review.contractId != null ? () => _openReviewForm(review) : null,
                          onDelete: () => _deleteReview(review),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Style.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Style.white.withValues(alpha: .16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Style.white, size: 18.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Style.getHeaderTwo(
              color: Style.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: Style.getTextStyle(color: Style.white.withValues(alpha: .86), fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Style.getCardColor(),
      elevation: 3,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24.w,
                  backgroundColor: Style.getPrimaryColor().withValues(alpha: .1),
                  backgroundImage: review.reviewerAvatarUrl.isNotEmpty ? NetworkImage(review.reviewerAvatarUrl) : null,
                  child: review.reviewerAvatarUrl.isEmpty
                      ? Icon(Icons.person_rounded, color: Style.getPrimaryColor())
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewedUserName,
                        style: Style.getHeaderTwo(
                          color: Style.getTextColor(),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        review.reviewedUserType,
                        style: Style.getTextStyle(
                          color: Style.getPrimaryColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      _stars(review.rating),
                      SizedBox(height: 6.h),
                      Text(
                        'Por ${review.reviewerName}',
                        style: Style.getTextStyle(color: Style.getObscureTextColor()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.hasComment) ...[
              SizedBox(height: 12.h),
              Text(
                review.comment,
                style: Style.getTextStyle(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w500,
                ).copyWith(height: 1.35),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_rounded, size: 16.w),
                    label: const Text('Editar'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline_rounded, size: 16.w),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Style.getErrorColor(),
                      side: BorderSide(color: Style.getErrorColor()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stars(double rating) {
    final safeRating = rating.clamp(0, 5);
    return Row(
      children: List.generate(5, (index) {
        final active = safeRating >= index + 1;
        return Icon(
          active ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: 16.w,
        );
      }),
    );
  }
}