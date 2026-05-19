import 'package:thuchanhweb/controllers/brand_controller.dart';
import 'package:thuchanhweb/controllers/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/attribute_controller.dart';
import 'controllers/coupon_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()..checkLogin()),
        ChangeNotifierProvider(create: (_) => CategoryController()..fetchCategories()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => AttributeController()),
        ChangeNotifierProvider(create: (_) => BrandController()..loadBrands()),
        ChangeNotifierProvider(create: (_) => CouponController()..fetchCoupons()),
      ],
      child: Builder(
        builder: (context) {
          final auth = context.watch<AuthController>();
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            // ADD THIS BLOCK
            localizationsDelegates: const [
              FlutterQuillLocalizations.delegate, // FIX LỖI
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('vi')],
            routerDelegate: AppRouterDelegate(auth),
            routeInformationParser: AppRouteParser(),
          );
        },
      ),
    );
  }
}
