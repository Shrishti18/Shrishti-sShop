import 'package:flutter/material.dart';
import 'package:myshop/providers/cart.dart';
import 'package:myshop/providers/orders.dart';
import 'package:myshop/screens/cart_screen.dart';
import 'package:myshop/screens/edit_product.dart';
import 'package:myshop/screens/splash.dart';
import 'package:provider/provider.dart';
import 'package:myshop/screens/product_details.dart';
import './screens/products_overview_screen.dart';
import './providers/product_provider.dart';
import './screens/order_screem.dart';
import './screens/user_product.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, ProductProvider>(
            create: (_) {},
            update: (ctx, auth, previousProducts) => ProductProvider(
                auth.token,
                auth.userId,
                previousProducts == null
                    ? []
                    : previousProducts
                        .items), //token is in Auth() so have to extractfrom there andsend to ProductProvider()
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) {},
            update: (ctx, auth, previousOrders) => Orders(
                auth.token,
                auth.userId,
                previousOrders == null
                    ? []
                    : previousOrders
                        .orders), //token is in Auth() so have to extractfrom there andsend to ProductProvider()
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, value, _) => MaterialApp(
            title: 'My Shop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
            ),
            home: value.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: value.tryautologin(),
                    builder: (ctx, authresult) =>
                        authresult.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              ProductDetail.routeName: (ctx) => ProductDetail(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("MyShop"),
//       ),
//       body: Text("hi"),
//     );
//   }
// }
