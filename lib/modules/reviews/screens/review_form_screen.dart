import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/reviews/models/review_model.dart';
import 'package:worklink_local/modules/reviews/services/reviews_service.dart';
import 'package:worklink_local/utils/utils.dart';

class ReviewFormScreen extends StatefulWidget {
  final int contractId;
  final int reviewedUserId;
  final String reviewedUserName;
  final String reviewedUserType;
  final int? reviewId;
  final ReviewModel? initialReview;

  const ReviewFormScreen({
    super.key,
    required this.contractId,
    required this.reviewedUserId,
    required this.reviewedUserName,
    required this.reviewedUserType,
    this.reviewId,
    this.initialReview,
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _saving = false;
  double _rating = 5;

  @override
  void initState() {
    super.initState();
    final review = widget.initialReview;
    if (review != null) {
      _rating = review.rating.clamp(1, 5).toDouble();
      _commentController.text = review.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;

    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      _showMessage('Escribe un comentario breve antes de guardar.');
      return;
    }

    setState(() => _saving = true);
    try {
      final review = widget.reviewId != null
          ? await ReviewsService.updateReview(
              reviewId: widget.reviewId!,
              rating: _rating,
              comment: comment,
            )
          : await ReviewsService.createReview(
              contractId: widget.contractId,
              reviewedUserId: widget.reviewedUserId,
              reviewedUserName: widget.reviewedUserName,
              reviewedUserType: widget.reviewedUserType,
              rating: _rating,
              comment: comment,
            );

      if (!mounted) return;
      Navigator.of(context).pop(review);
    } on ReviewsFlowException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    Dialogs.showSimpleDialog(
      context,
      title: 'Calificaciones',
      message: message,
      color: Style.getErrorColor(),
      icon: Icons.error_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        surfaceTintColor: Style.transparent,
        title: Text(
          widget.reviewId != null ? 'Editar reseña' : 'Calificar experiencia',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(Style.horizontalPadding.w),
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Style.getCardColor(),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reviewedUserName,
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.reviewedUserType,
                  style: Style.getTextStyle(
                    color: Style.getPrimaryColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Tu calificación',
                  style: Style.getTextStyle(
                    color: Style.getObscureTextColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final active = _rating >= starValue;
                    return IconButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _rating = starValue.toDouble()),
                      icon: Icon(
                        active ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 28.w,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 14.h),
                TextField(
                  controller: _commentController,
                  maxLines: 5,
                  maxLength: 600,
                  decoration: InputDecoration(
                    labelText: 'Comentario',
                    hintText: 'Cuéntanos cómo fue la experiencia con esta persona.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Style.getPrimaryColor(),
                      foregroundColor: Style.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Style.white,
                            ),
                          )
                        : Text(
                            widget.reviewId != null ? 'Actualizar' : 'Publicar reseña',
                            style: Style.getHeaderThree(
                              color: Style.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}