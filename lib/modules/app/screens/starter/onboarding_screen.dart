import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/main.dart';
import 'package:worklink_local/modules/app/models/onboarding_item_model.dart';
import '../../../../utils/utils.dart';
import 'login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  static String tag = '/OnBoardingScreen';

  const OnBoardingScreen({super.key});

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {
  int? currentIndex = 0;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  int _currentPage = 0;
  bool _isOnPageTurning = false;

  @override
  void initState() {
    super.initState();
    pageController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_isOnPageTurning &&
        pageController.page == pageController.page!.roundToDouble()) {
      setState(() {
        _currentPage = pageController.page!.toInt();
        _isOnPageTurning = false;
      });
    } else if (!_isOnPageTurning &&
        _currentPage.toDouble() != pageController.page) {
      if ((_currentPage.toDouble() - pageController.page!).abs() > 0.7) {
        setState(() {
          _isOnPageTurning = true;
        });
      }
    }
  }

  List<OnboardingItem> onboardingList = [
    OnboardingItem(
      name: MultiLanguages.of(
        navigatorKey.currentState!.context,
      )!.translate('intro_one_title'),
      text: MultiLanguages.of(
        navigatorKey.currentState!.context,
      )!.translate('intro_one_text'),
      icon: FontAwesomeIcons.briefcase,
    ),

    OnboardingItem(
      name: MultiLanguages.of(
        navigatorKey.currentState!.context,
      )!.translate('intro_two_title'),
      text: MultiLanguages.of(
        navigatorKey.currentState!.context,
      )!.translate('intro_two_text'),
      icon: FontAwesomeIcons.users,
    ),

    OnboardingItem(
      name: MultiLanguages.of(
        navigatorKey.currentState!.context,
      )!.translate('intro_three_title'),
      text: MultiLanguages.of(
        navigatorKey.currentState!.context,
      )!.translate('intro_three_text'),
      icon: FontAwesomeIcons.bullhorn,
    ),

    OnboardingItem(
      name: MultiLanguages.of(
        navigatorKey.currentState!.context,
      )!.translate('intro_four_title'),
      text: MultiLanguages.of(
        navigatorKey.currentState!.context,
      )!.translate('intro_four_text'),
      icon: FontAwesomeIcons.rocket,
    ),
  ];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.darkScaffoldColor,
        body: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: onboardingList.length,
              controller: pageController,
              itemBuilder: (context, i) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Style.pink.withValues(alpha: .15),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          onboardingList[i].icon,
                          size: 70,
                          color: Style.white,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Text(
                        onboardingList[i].name,
                        textAlign: TextAlign.center,
                        style: Style.getHeaderOne(color: Style.white),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          onboardingList[i].text,
                          textAlign: TextAlign.center,
                          style: Style.getHeaderThree(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onPageChanged: (int i) {
                currentIndex = i;
                setState(() {});
              },
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                } else if (details.delta.dx < 0) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Style.kingBlue.withValues(alpha: 0.3),
                      Style.getPrimaryColor().withValues(alpha: 0.3),
                      Style.getSecondaryColor().withValues(alpha: 0.3),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 30.h,
              right: 10.w,
              left: 10.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Language Button not needed for now
                  IconButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Style.black.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: Style.getBorderRadius()
                      ),
                    ),
                    onPressed: () => app.changeLanguage(context),
                    icon: Icon(
                      FontAwesomeIcons.globe,
                      color: Style.white,
                      size: 20.w,
                    ),
                  ),
                  */
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Style.black.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: Style.getBorderRadius(),
                      ),
                    ),
                    onPressed: () {
                      AppSettings.doneOnboarding = true;

                      Navigator.pushReplacement(
                        context,
                        Transitions.fadeTransition(
                          const LoginScreen(showByeMesssage: false),
                        ),
                      );
                    },
                    child: Text(
                      MultiLanguages.of(context)!.translate('skip'),
                      style: Style.getHeaderTwo(
                        color: Style.white,
                        fontSize: 12.w,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 20.h,
              right: 10.w,
              left: 10.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (currentIndex! < onboardingList.length - 1) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        AppSettings.doneOnboarding = true;

                        Navigator.pushReplacement(
                          context,
                          Transitions.fadeTransition(
                            const LoginScreen(showByeMesssage: false),
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentIndex == onboardingList.length - 1
                          ? 170.w
                          : 60.h,
                      height: 60.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Style.getPrimaryColor(),
                            Style.getSecondaryColor(),
                          ],
                        ),
                        borderRadius: currentIndex == onboardingList.length - 1
                            ? BorderRadius.circular(30)
                            : BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
                            color: Style.getPrimaryColor().withValues(
                              alpha: .35,
                            ),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: currentIndex == onboardingList.length - 1
                            ? Row(
                                key: const Key('start'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    MultiLanguages.of(
                                      context,
                                    )!.translate('start'),
                                    style: Style.getHeaderTwo(
                                      color: Style.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  const FaIcon(
                                    FontAwesomeIcons.rocket,
                                    color: Colors.white,
                                  ),
                                ],
                              )
                            : const FaIcon(
                                key: Key('next'),
                                FontAwesomeIcons.arrowRight,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                  dotIndicator(onboardingList, currentIndex, isPersonal: false),
                ],
              ),
            ),

            Positioned(
              bottom: 100.h,
              right: 10.w,
              left: 10.w,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dotIndicator(list, i, {bool isPersonal = false}) {
    return SizedBox(
      height: 16.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(list.length, (ind) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isPersonal == true ? 6.h : 4.h,
            width: isPersonal == true ? 6.h : 20.h,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: i == ind
                  ? AppSettings.isDarkModeOn == true
                        ? Style.white
                        : Style.white
                  : Colors.grey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
          );
        }),
      ),
    );
  }
}
