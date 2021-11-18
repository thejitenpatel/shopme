import 'package:get/get.dart';
import 'package:shopme/src/constants/app_constants.dart';
import 'package:shopme/src/models/product_models.dart';
import 'package:shopme/src/services/http_service.dart';
import 'package:dio/dio.dart' as d;

class ProductController extends GetxController {
  var isLoading = true.obs;
  var productList = [].obs;
  HttpService httpService = HttpService();

  @override
  void onInit() {
    httpService.init();
    fetchProducts();
    super.onInit();
  }

  void fetchProducts() async {
    try {
      isLoading(true);
      final result =
          await httpService.request(url: "products", method: Method.GET);
      if (result != null) {
        if (result is d.Response) {
          var products = List<ProductsModel>.from(
              (result.data).map((x) => ProductsModel.fromJson(x)));
          productList.value = products;
          logger.d(products);
        } else {
          isLoading(false);
        }
      }
    } finally {
      isLoading(false);
    }
  }
}
