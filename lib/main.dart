import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/Admin/AddProductPage.dart';
import 'package:shopping_app/Admin/AdminDashboard.dart';
import 'package:shopping_app/Admin/AdminOrderPage.dart';
import 'package:shopping_app/Admin/ManageAdminPage.dart';
import 'package:shopping_app/Admin/UserProplemPage.dart';
import 'package:shopping_app/Cubit/AddProduct/product_cubit.dart';
import 'package:shopping_app/Cubit/Admin/AuthCubit.dart';
import 'package:shopping_app/Screens/AddressEntryPage.dart';
import 'package:shopping_app/Screens/CallUsPage.dart';
import 'package:shopping_app/Screens/CartPage.dart';
import 'package:shopping_app/Screens/ChangePasswordPage.dart';
import 'package:shopping_app/Screens/FavoritePage.dart';
import 'package:shopping_app/Screens/HomeMainView.dart';
import 'package:shopping_app/Screens/Home_Page.dart';
import 'package:shopping_app/Screens/Login_page.dart';
import 'package:shopping_app/Screens/OrderPage.dart';
import 'package:shopping_app/Screens/ProductPageDetail.dart';
import 'package:shopping_app/Screens/Product_Page.dart';
import 'package:shopping_app/Screens/ProfilePage.dart';
import 'package:shopping_app/Screens/Register_page.dart';
import 'package:shopping_app/Screens/splash_screen.dart';
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
