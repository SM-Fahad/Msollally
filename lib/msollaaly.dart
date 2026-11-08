import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:msollaally/routes/app_route.dart';
import 'core/bindings/controller_binder.dart';
import 'core/utils/theme/theme.dart';
import 'core/widgets/session_guard.dart';

class Msollaaly extends StatelessWidget {
  const Msollaaly({super.key});

  static String initialRoute = AppRoute.splashScreen;

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: ScreenUtilInit(
        designSize: Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          final easyLoadingBuilder = EasyLoading.init();
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, appChild) {
              final builtChild = easyLoadingBuilder(context, appChild);
              return SessionGuard(child: builtChild);
            },
            initialRoute: initialRoute,
            getPages: AppRoute.routes,
            initialBinding: ControllerBinder(),
            themeMode: ThemeMode.system,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
