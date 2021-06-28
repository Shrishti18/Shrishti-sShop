import 'package:flutter/material.dart';
import 'package:myshop/providers/product_provider.dart';
import 'package:myshop/widgets/app_drawer.dart';
import '../screens/cart_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import '../providers/cart.dart';
import '../providers/product_provider.dart';

enum FilterOption {
  Favourite,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = '/productoverview';

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavourites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // //just when its is created,only oncee
    // // TODO: implement initState
    // //Provider.of<ProductProvider>(context).fetchAndSetProducts();
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<ProductProvider>(context).fetchAndSetProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<ProductProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
        // _isLoading = false;
      });
    }
    _isInit = false;
    //run multiple times but before the builde is created for the firsttimeand after the widgets are placed

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productsContainer = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("MyShop"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption selectedvalue) {
              setState(() {
                if (selectedvalue == FilterOption.Favourite) {
                  _showOnlyFavourites = true;
                  // productsContainer.showFavouritesOnly();

                } else {
                  _showOnlyFavourites = false;
                  // productsContainer.showAll();
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Only Favourite'), value: FilterOption.Favourite),
              PopupMenuItem(
                child: Text('show all'),
                value: FilterOption.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          // ignore: missing_required_param
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              child: child,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                }),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavourites),
    );
  }
}
