import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  ForgotPasswordDialogState createState() => ForgotPasswordDialogState();
}

class ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Style.getBackgroundColor(),
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      title: Text(
        MultiLanguages.of(context)!.translate('Ingresar correo electrónico'),
        style: Style.getHeaderTwo(
          color: Style.getPrimaryColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Ingrese su correo electrónico para restablecer su contraseña",
            style: Style.getHeaderThree(
              color: Style.getTextColor(),
              fontWeight: FontWeight.normal,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            "Correo electrónico",
            style: Style.getHeaderThree(
              color: Style.getTextColor(),
              fontWeight: FontWeight.normal,
            ),
          ),

          const SizedBox(height: 5),

          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: Style.getTextStyle(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Style.circularBorderRadius,
                  ),
                  borderSide: const BorderSide(color: Style.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Style.circularBorderRadius,
                  ),
                  borderSide: BorderSide(color: Style.getPrimaryColor()),
                ),
                prefixIcon: Icon(
                  Icons.mail_rounded,
                  color: Style.getPrimaryColor(),
                  size: Style.bigIconSize,
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Por favor, ingrese su correo electrónico";
                } else {
                  if (!value.isEmail) {
                    return "Por favor, ingrese un correo electrónico válido";
                  }

                  return null;
                }
              },
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Style.getBackgroundColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Style.circularBorderRadius),
              side: BorderSide(color: Style.getPrimaryColor()),
            ),
          ),
          child: Text(
            "Cancelar",
            style: Style.getHeaderThree(color: Style.getPrimaryColor()),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Implement password reset functionality
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Style.getPrimaryColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Style.circularBorderRadius),
              side: BorderSide(color: Style.getPrimaryColor()),
            ),
          ),
          child: Text(
            "Enviar",
            style: Style.getHeaderThree(color: Style.white),
          ),
        ),
      ],
    );
  }
}
