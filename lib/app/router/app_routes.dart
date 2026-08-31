/// Central route path constants — no screen should hardcode a path string.
class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const pending = '/pending';

  static const home = '/home';
  static const orders = '/orders';
  static const products = '/products';
  static const money = '/money';
  static const newProduct = '/products/new';
  static const productCategory = '/products/form/category';
  static const productMoreCategories = '/products/form/more-categories';
  static const productTaxClass = '/products/form/tax-class';
  static const productStatus = '/products/form/status';
  static const productAddOption = '/products/form/add-option';

  static const notifications = '/notifications';
  static const requests = '/requests';

  static const account = '/account';
  static const storeDetails = '/account/store-details';
  static const payoutAccount = '/account/payout-account';
  static const shipping = '/account/shipping';
  static const team = '/account/team';
  static const teamAdd = '/account/team/add';
  static const profile = '/account/profile';
  static const password = '/account/password';
  static const devices = '/account/devices';

  static String orderDetailPath(int id) => '/orders/order/$id';
  static String orderFulfilPath(int id) => '/orders/order/$id/fulfil';
  static String productDetailPath(int id) => '/products/product/$id';
  static String productOptionPath(int attributeId) => '/products/form/option/$attributeId';
  static String productVariantPath(int index) => '/products/form/variant/$index';
  static String payoutDetailPath(int id) => '/money/payout/$id';
  static String requestDetailPath(int id) => '/requests/request/$id';
}
