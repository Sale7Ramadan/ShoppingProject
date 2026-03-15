import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/features/admin/views/add_product_page.dart';
import 'package:shopping_app/features/admin/views/admin_dashboard.dart';
import 'package:shopping_app/features/admin/views/admin_order_page.dart';
import 'package:shopping_app/features/admin/views/manage_admin_page.dart';
import 'package:shopping_app/features/admin/views/user_proplem_page.dart';
import 'package:shopping_app/features/admin/cubit/product_cubit.dart';
import 'package:shopping_app/features/admin/cubit/auth_cubit.dart';
import 'package:shopping_app/features/cart/views/address_entry_page.dart';
import 'package:shopping_app/core/views/call_us_page.dart';
import 'package:shopping_app/features/cart/views/cart_page.dart';
import 'package:shopping_app/features/auth/views/change_password_page.dart';
import 'package:shopping_app/features/products/views/favorite_page.dart';
import 'package:shopping_app/features/products/views/home_main_view.dart';
import 'package:shopping_app/features/products/views/home_page.dart';
import 'package:shopping_app/features/auth/views/login_page.dart';
import 'package:shopping_app/features/orders/views/order_page.dart';
import 'package:shopping_app/features/products/views/product_page_detail.dart';
import 'package:shopping_app/features/products/views/product_page.dart';
import 'package:shopping_app/features/profile/views/profile_page.dart';
import 'package:shopping_app/features/auth/views/register_page.dart';
import 'package:shopping_app/core/views/splash_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.white,
    ),
  );
  runApp(const K_Shoes());
}

class K_Shoes extends StatelessWidget {
  const K_Shoes({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductCubit>(create: (_) => ProductCubit()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: 'splachscreen',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        routes: {
          AdminDashboard.id: (context) => AdminDashboard(),
          AddProductPage.id: (context) => AddProductPage(),
          ProductPage.id: (context) => ProductPage(),
          CartPage.id: (context) => CartPage(),
          OrdersPage.id: (context) => OrdersPage(),
          ChangePasswordPage.id: (context) => ChangePasswordPage(),
          HomeMainView.id: (context) => HomeMainView(),
          FavoritePage.id: (context) => FavoritePage(),
          ProfilePage.id: (context) => ProfilePage(),
          ContactUsPage.id: (context) => ContactUsPage(),
          AdminOrdersPage.id: (context) => AdminOrdersPage(),
          HomePage.id: (context) => HomePage(),
          AddressEntryPage.id: (context) => AddressEntryPage(),
          RegisterPage.id: (context) => RegisterPage(),
          LoginPage.id: (context) => LoginPage(),
          UserProblemPage.id: (context) => UserProblemPage(),
          ManageAdminsPage.id: (context) => ManageAdminsPage(),
          'splachscreen': (context) => SplashScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ProductDetailsPage.id) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ProductDetailsPage(productData: args),
            );
          }
          return null;
        },
      ),
    );
  }
}
