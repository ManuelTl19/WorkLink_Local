import 'package:worklink_local/helpers/helpers.dart';

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Style.red,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${MultiLanguages.of(context)!.
          translate('something_went_rong')}: ${errorDetails.exceptionAsString()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
