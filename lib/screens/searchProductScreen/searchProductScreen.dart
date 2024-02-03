import 'package:GreenfieldNaturals/helper/utils/generalImports.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({Key? key}) : super(key: key);

  @override
  State<ProductSearchScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductSearchScreen> {
  // search provider controller
  final TextEditingController edtSearch = TextEditingController();

  //give delay to live search
  Timer? delayTimer;

  ScrollController scrollController = ScrollController();

  scrollListener() async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (context.read<ProductSearchProvider>().hasMoreData) {
        Map<String, String> params = await Constant.getProductsDefaultParams();

        params[ApiAndParams.search] = edtSearch.text.trim();

        await context
            .read<ProductSearchProvider>()
            .getProductSearchProvider(context: context, params: params);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    edtSearch.addListener(searchTextListener);
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void searchTextListener() {
    if (edtSearch.text.isEmpty) {
      delayTimer?.cancel();
    }

    if (delayTimer?.isActive ?? false) delayTimer?.cancel();

    delayTimer = Timer(const Duration(milliseconds: 500), () {
      if (edtSearch.text.isNotEmpty) {
        if (edtSearch.text.length !=
            context.read<ProductSearchProvider>().searchedTextLength) {
          callApi(isReset: true);
          context.read<ProductSearchProvider>().setSearchLength(edtSearch.text);
        }
      }
    });
  }

  callApi({required bool isReset}) async {
    if (isReset) {
      context.read<ProductSearchProvider>().offset = 0;

      context.read<ProductSearchProvider>().products = [];
    }

    Map<String, String> params = await Constant.getProductsDefaultParams();

    params[ApiAndParams.sort] = ApiAndParams.productListSortTypes[
        context.read<ProductSearchProvider>().currentSortByOrderIndex];
    params[ApiAndParams.search] = edtSearch.text.trim().toString();

    await context
        .read<ProductSearchProvider>()
        .getProductSearchProvider(context: context, params: params);
  }

  @override
  Widget build(BuildContext context) {
    List lblSortingDisplayList = [
      "sorting_display_list_default",
      "sorting_display_list_newest_first",
      "sorting_display_list_oldest_first",
      "sorting_display_list_price_high_to_low",
      "sorting_display_list_price_low_to_high",
      "sorting_display_list_discount_high_to_low",
      "sorting_display_list_popularity",
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
              jsonKey: "search",
              softWrap: true,
              style: TextStyle(color: ColorsRes.mainTextColor)),
          actions: [setCartCounter(context: context)]),
      body: Column(
        children: [
          searchWidget(),
          Widgets.getSizedBox(
            height: Constant.size5,
          ),
          if (context.watch<ProductSearchProvider>().products.length > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Constant.size5),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pushNamed(
                          context,
                          productListFilterScreen,
                          arguments: [
                            context
                                .read<ProductSearchProvider>()
                                .productList
                                .brands,
                            double.parse(context
                                .read<ProductSearchProvider>()
                                .productList
                                .maxPrice),
                            double.parse(context
                                .read<ProductSearchProvider>()
                                .productList
                                .minPrice),
                            context
                                .read<ProductSearchProvider>()
                                .productList
                                .sizes
                          ],
                        ).then((value) async {
                          if (value == true) {
                            context.read<ProductSearchProvider>().offset = 0;
                            context.read<ProductSearchProvider>().products = [];

                            callApi(isReset: true);
                          }
                        });
                      },
                      child: Card(
                          color: Theme.of(context).cardColor,
                          elevation: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Widgets.defaultImg(
                                  image: "filter_icon",
                                  height: 17,
                                  width: 17,
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 7, bottom: 7, end: 7),
                                  iconColor: Theme.of(context).primaryColor),
                              CustomTextLabel(
                                jsonKey: "filter",
                                softWrap: true,
                              )
                            ],
                          )),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          shape: DesignConfig.setRoundedBorderSpecific(20,
                              istop: true),
                          builder: (BuildContext context1) {
                            return Wrap(
                              children: [
                                Container(
                                  padding: EdgeInsetsDirectional.only(
                                      start: Constant.size15,
                                      end: Constant.size15,
                                      top: Constant.size15,
                                      bottom: Constant.size15),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          PositionedDirectional(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Widgets.defaultImg(
                                                  image: "ic_arrow_back",
                                                  iconColor:
                                                      ColorsRes.mainTextColor,
                                                  height: 15,
                                                  width: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: CustomTextLabel(
                                              jsonKey: "sort_by",
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .merge(
                                                    TextStyle(
                                                      letterSpacing: 0.5,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: ColorsRes
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Widgets.getSizedBox(height: 10),
                                      Column(
                                        children: List.generate(
                                          ApiAndParams
                                              .productListSortTypes.length,
                                          (index) {
                                            return GestureDetector(
                                              onTap: () async {
                                                Navigator.pop(context);
                                                context
                                                    .read<
                                                        ProductSearchProvider>()
                                                    .products = [];

                                                context
                                                    .read<
                                                        ProductSearchProvider>()
                                                    .offset = 0;

                                                context
                                                    .read<
                                                        ProductSearchProvider>()
                                                    .currentSortByOrderIndex = index;

                                                callApi(isReset: true);
                                              },
                                              child: Container(
                                                padding:
                                                    EdgeInsetsDirectional.all(
                                                        10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    context
                                                                .read<
                                                                    ProductSearchProvider>()
                                                                .currentSortByOrderIndex ==
                                                            index
                                                        ? Icon(
                                                            Icons
                                                                .radio_button_checked,
                                                            color: ColorsRes
                                                                .appColor,
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .radio_button_off,
                                                            color: ColorsRes
                                                                .appColor,
                                                          ),
                                                    Widgets.getSizedBox(
                                                        width: 10),
                                                    Expanded(
                                                      child: CustomTextLabel(
                                                        jsonKey:
                                                            lblSortingDisplayList[
                                                                index],
                                                        softWrap: true,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .merge(
                                                              TextStyle(
                                                                letterSpacing:
                                                                    0.5,
                                                                fontSize: 16,
                                                                color: ColorsRes
                                                                    .mainTextColor,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        color: Theme.of(context).cardColor,
                        elevation: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Widgets.defaultImg(
                                image: "sorting_icon",
                                height: 17,
                                width: 17,
                                padding: const EdgeInsetsDirectional.only(
                                    top: 7, bottom: 7, end: 7),
                                iconColor: Theme.of(context).primaryColor),
                            CustomTextLabel(
                              jsonKey: "sort_by",
                              softWrap: true,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<ProductChangeListingTypeProvider>()
                            .changeListingType();
                      },
                      child: Card(
                          color: Theme.of(context).cardColor,
                          elevation: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Widgets.defaultImg(
                                  image: context
                                              .watch<
                                                  ProductChangeListingTypeProvider>()
                                              .getListingType() ==
                                          false
                                      ? "grid_view_icon"
                                      : "list_view_icon",
                                  height: 17,
                                  width: 17,
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 7, bottom: 7, end: 7),
                                  iconColor: Theme.of(context).primaryColor),
                              CustomTextLabel(
                                text: context
                                            .watch<
                                                ProductChangeListingTypeProvider>()
                                            .getListingType() ==
                                        false
                                    ? getTranslatedValue(
                                        context,
                                        "grid_view",
                                      )
                                    : getTranslatedValue(
                                        context,
                                        "list_view",
                                      ),
                                softWrap: true,
                              )
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: context.read<ProductSearchProvider>().searchedTextLength > 0
                ? setRefreshIndicator(
                    refreshCallback: () async {
                      if (context
                              .read<ProductSearchProvider>()
                              .searchedTextLength >
                          0) {
                        context.read<ProductSearchProvider>().offset = 0;
                        context.read<ProductSearchProvider>().products = [];
                      }

                      callApi(isReset: true);
                    },
                    child: ListView(
                      controller: scrollController,
                      children: [
                        productWidget(),
                      ],
                    ),
                  )
                : ListView(
                    controller: scrollController,
                    children: [
                      productWidget(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  //Start search widget
  searchWidget() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.symmetric(
          horizontal: Constant.size10, vertical: Constant.size10),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: DesignConfig.boxDecoration(
                Theme.of(context).scaffoldBackgroundColor, 10),
            child: ListTile(
              title: TextField(
                autofocus: true,
                style: TextStyle(
                  color: ColorsRes.mainTextColor,
                ),
                controller: edtSearch,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: context
                          .read<LanguageProvider>()
                          .currentLanguage["product_search_hint"] ??
                      "product_search_hint",
                ),
              ),
              // onChanged: onSearchTextChanged,
              contentPadding: const EdgeInsetsDirectional.only(start: 10),
              trailing: IconButton(
                padding: EdgeInsets.zero,
                icon: Consumer<ProductSearchProvider>(
                  builder: (context, productSearchProvider, _) {
                    return edtSearch.text.isNotEmpty
                        ? Icon(Icons.close)
                        : Icon(Icons.search);
                  },
                ),
                onPressed: () async {
                  if (edtSearch.text.trim().length > 0) {
                    edtSearch.clear();
                    context.read<ProductSearchProvider>().setSearchLength("");
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(width: Constant.size10),
        GestureDetector(
          onTap: () async {
            final permissionMicrophone = Permission.microphone;
            final status = await permissionMicrophone.request();
            if (status.isGranted) {
              bottomSheetVoiceRecognition();
            } else if (status.isPermanentlyDenied) {
              openAppSettings();
            } else {
              permissionMicrophone.request();
              print('microphone permission denied.');
            }
          },
          child: Container(
            decoration: DesignConfig.boxGradient(10),
            padding: EdgeInsets.symmetric(
                horizontal: Constant.size14, vertical: Constant.size14),
            child: Widgets.defaultImg(
              image: "voice_search_icon",
              iconColor: ColorsRes.mainIconColor,
            ),
          ),
        ),
      ]),
    );
  }

  //End search widget

  productWidget() {
    return Consumer<ProductSearchProvider>(
      builder: (context, productSearchProvider, _) {
        List<ProductListItem> products = productSearchProvider.products;

        if (productSearchProvider.productSearchState ==
            ProductSearchState.loading) {
          return getProductListShimmer(
              context: context,
              isGrid: context
                  .read<ProductChangeListingTypeProvider>()
                  .getListingType());
        } else if (productSearchProvider.productSearchState ==
                ProductSearchState.loaded ||
            productSearchProvider.productSearchState ==
                ProductSearchState.loadingMore) {
          return Column(
            children: [
              context
                          .read<ProductChangeListingTypeProvider>()
                          .getListingType() ==
                      true
                  ? /* GRID VIEW UI */ GridView.builder(
                      itemCount: products.length,
                      padding: EdgeInsetsDirectional.only(
                          start: Constant.size10,
                          end: Constant.size10,
                          bottom: Constant.size10,
                          top: Constant.size5),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return ProductGridItemContainer(
                            product: products[index]);
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.8,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                    )
                  : /* LIST VIEW UI */ Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(products.length, (index) {
                        return ProductListItemContainer(
                            product: products[index]);
                      }),
                    ),
              if (productSearchProvider.productSearchState ==
                  ProductSearchState.loadingMore)
                getProductItemShimmer(
                    context: context,
                    isGrid: context
                        .read<ProductChangeListingTypeProvider>()
                        .getListingType()),
            ],
          );
        } else if (productSearchProvider.productSearchState ==
                ProductSearchState.initial ||
            context.read<ProductSearchProvider>().searchedTextLength == 0) {
          return DefaultBlankItemMessageScreen(
            title: "",
            description: "enter_text_to_search_the_products",
            image: "no_search_found_icon",
          );
        } else if (productSearchProvider.productSearchState ==
            ProductSearchState.empty) {
          return DefaultBlankItemMessageScreen(
            title: "empty_product_list_message",
            description: "empty_product_list_description",
            image: "no_product_icon",
          );
        } else {
          return NoInternetConnectionScreen(
              height: MediaQuery.of(context).size.height * 0.65,
              message: productSearchProvider.message,
              callback: () {
                callApi(isReset: false);
              });
        }
      },
    );
  }

  bottomSheetVoiceRecognition() {
    showModalBottomSheet<String?>(
        context: context,
        isScrollControlled: false,
        shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
        builder: (context) {
          return ChangeNotifierProvider<VoiceSearchProvider>(
            create: (context) => VoiceSearchProvider(),
            child: SpeechToTextSearch(),
          );
        }).then((value) {
      if (value != null && value.isNotEmpty) {
        edtSearch.text = value;
      }
    });
  }
}
