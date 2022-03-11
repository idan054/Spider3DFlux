import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../models/index.dart' show Product;
// import '../../modules/booking/booking.dart';
import '../../screens/detail/widgets/index.dart';
import '../../services/index.dart';

class DialogAddToCart {
  static void show(BuildContext context, {required Product product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
        ),
        child: Stack(
          children: [
            RubberAddToCart(product: product),
/*            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(
                    CupertinoIcons.xmark_circle,
                    size: 30,
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}

class RubberAddToCart extends StatefulWidget {
  late final Product product;
  RubberAddToCart({required this.product});

  @override
  _StateRubberAddToCart createState() => _StateRubberAddToCart();
}

class _StateRubberAddToCart extends State<RubberAddToCart> {
  bool isLoading = true;
  late Product product;

  @override
  void initState() {
    Future.microtask(() async {
      setState(() {
        product = widget.product;
      });
      product = (await Services().widget.getProductDetail(context, product)) ??
          widget.product;
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  Widget renderProductInfo() {
    var body;
    if (isLoading == true) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: kLoadingWidget(context),
      );
    } else {
      switch (product.type) {
        // case 'appointment':
        //   return ProductBookingLayout(
        //     key: ValueKey('keyProducts${product.id}'),
        //     product: product,
        //   );
        case 'booking':
          body = ListingBooking(product);
          break;
        case 'grouped':
          body = GroupedProduct(product);
          break;
        default:
          body = ProductVariant(
            product,
            onSelectVariantImage: (String url) {},
          );
      }
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 20),
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProductTitle(product),
        ),
        renderProductInfo(),
      ],
    );
  }
}
