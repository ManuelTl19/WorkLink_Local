import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/screens/starter/login_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  init() async {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward().whenComplete(() async {
      if (AppSettings.doneOnboarding && mounted) {
        push(context, const LoginScreen(showByeMesssage: false), replace: true);
      } else {
        if (mounted) push(context, const OnBoardingScreen(), replace: true);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(color: Style.getBackgroundColor()),

        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Style.getPrimaryColor().withOpacity(.10),
                  ),
                ),
              ),

              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Style.getSecondaryColor().withOpacity(.10),
                  ),
                ),
              ),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Style.getBackgroundColor(),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Style.getBackgroundColor()),
                  ),
                  child: SizedBox(
                    width: 260.w,
                    height: 260.w,
                    child: Image.asset(
                      AppSettings.isDarkModeOn
                          ? Assets.companyHorDarkLogo
                          : Assets.companyHorLightLogo,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Style.getTextColor(),
                  ),
                ),
              ),

              Padding(
                padding: Style.getPadding(),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: Text(
                            'Conectando oportunidades',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: Style.getHeaderTwo(
                              color: Style.getTextColor().withOpacity(.5),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
