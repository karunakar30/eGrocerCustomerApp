import 'package:GreenfieldNaturals/helper/utils/generalImports.dart';
import 'package:GreenfieldNaturals/screens/getLocationScreen.dart';

export 'package:google_maps_webservice/places.dart';

class GetLocation extends StatefulWidget {
  final String from;

  const GetLocation({Key? key, required this.from}) : super(key: key);

  @override
  State<GetLocation> createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> {
  final TextEditingController edtAddress = TextEditingController();
  late GeoAddress selectedAddress;

  List<GeoAddress> recentAddressList = [];
  List addressPlaceIdList = [];
  final recentAddressController = StreamController<GeoAddress>.broadcast();
  bool visibleRecentWidget = false;

  @override
  void initState() {
    super.initState();
    recentAddressData();
  }

  recentAddressData() {
    String recentAddresses =
        Constant.session.getData(SessionManager.keyRecentAddressSearch);
    if (recentAddresses.trim().isNotEmpty) {
      var addressJson = jsonDecode(recentAddresses)["address"] as List;

      recentAddressList.addAll(addressJson.map((e) {
        GeoAddress address = GeoAddress.fromJson(e);
        addressPlaceIdList.add(address.placeId);
        return address;
      }).toList());
      visibleRecentWidget = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: "select_location",
            softWrap: true,
            style: TextStyle(
              color: ColorsRes.mainTextColor,
            ),
          ),
          onTap: () => Navigator.pop(context, true),
        ),
        body: ListView(
            padding: EdgeInsets.symmetric(
                horizontal: Constant.size10, vertical: Constant.size10),
            children: [
              lblSelectLocation(),
              if (visibleRecentWidget) recentAddressWidget(),
            ]),
      ),
    );
  }

  recentAddressWidget() {
    return Card(
        shape: DesignConfig.setRoundedBorder(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Constant.size10, vertical: Constant.size12),
            child: CustomTextLabel(
              jsonKey: "recent_searches",
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorsRes.mainTextColor,
              ),
            ),
          ),
          const Divider(
            height: 1,
          ),
          recentAddressesListWidget()
        ]));
  }

  lblSelectLocation() {
    return Card(
      shape: DesignConfig.setRoundedBorder(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Constant.size10, vertical: Constant.size12),
          child: CustomTextLabel(
            jsonKey: "select_delivery_location",
            softWrap: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorsRes.mainTextColor,
            ),
          ),
        ),
        const Divider(
          height: 1,
        ),
        TextButton.icon(
          onPressed: () async {
            await GeneralMethods.determinePosition().then((value) {
              GeoAddress getAddress = GeoAddress(
                  lattitud: value.latitude.toString(),
                  longitude: value.longitude.toString());

              Navigator.pushNamed(context, confirmLocationScreen,
                  arguments: [getAddress, widget.from]);
            });
          },
          icon: Icon(
            Icons.my_location_rounded,
            color: ColorsRes.appColor,
          ),
          label: CustomTextLabel(
            jsonKey: "use_my_current_location",
            softWrap: true,
            style: TextStyle(color: ColorsRes.appColor, letterSpacing: 0.5),
          ),
        ),
        Row(children: [
          const Expanded(
              child: Divider(
            height: 1,
          )),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Constant.size5),
            child: CustomTextLabel(
              jsonKey: "or",
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                height: 0.5,
                color: ColorsRes.mainTextColor,
              ),
            ),
          ),
          const Expanded(
              child: Divider(
            height: 1,
          )),
        ]),
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Constant.size10, vertical: Constant.size12),
            child: Widgets.textFieldWidget(
                edtAddress,
                GeneralMethods.emptyValidation,
                getTranslatedValue(
                  context,
                  "type_location_manually",
                ),
                TextInputType.text,
                getTranslatedValue(
                  context,
                  "type_location_manually",
                ),
                context,
                currfocus: AlwaysDisabledFocusNode(),
                hint: getTranslatedValue(
                  context,
                  "type_location_manually",
                ),
                floatingLbl: false,
                borderRadius: 8,
                bgcolor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: EdgeInsets.symmetric(
                    vertical: Constant.size5, horizontal: Constant.size10),
                tapCallback: () => searchAddress)),
      ]),
    );
  }

  searchAddress() {
    Future.delayed(Duration.zero, () async {
      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: Constant.googleApiKey,


        onError: (PlacesAutocompleteResponse response) {},
        mode: Mode.overlay,
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: ColorsRes.mainTextColor,
          )
        ),
        components: [],
        types: [],
        strictbounds: false,
        logo: const SizedBox(
          width: double.maxFinite,
          height: 0,
        ),
      );

      await GeneralMethods.displayPrediction(p, context)
          .then((value) => getRedirects(value));
    });
  }

  getRedirects(GeoAddress? value) {
    if (value != null) {
      if (!addressPlaceIdList.contains(value.placeId)) {
        if (!visibleRecentWidget) {
          visibleRecentWidget = true;
          recentAddressList.add(value);
          setState(() {});
        }
        addressPlaceIdList.add(value.placeId);
        recentAddressController.sink.add(value);
      }
      edtAddress.text = value.address!;
      selectedAddress = value;

      Navigator.pushNamed(context, confirmLocationScreen,
          arguments: [value, widget.from]);
    }
  }

  recentAddressesListWidget() {
    return StreamBuilder(
        stream: recentAddressController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            recentAddressList.insert(0, snapshot.data as GeoAddress);
          }
          return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                GeoAddress address = recentAddressList[index];
                return ListTile(
                  leading: Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Widgets.defaultImg(
                            image: "search_icon",
                            iconColor: ColorsRes.appColor)),
                  ),
                  title: CustomTextLabel(text: address.city ?? ""),
                  subtitle: CustomTextLabel(text: address.address ?? ""),
                  onTap: () {
                    Navigator.pushNamed(context, confirmLocationScreen,
                        arguments: [address, widget.from]);
                  },
                );
              }),
              separatorBuilder: (context, index) {
                return const SizedBox(height: 8);
              },
              itemCount: recentAddressList.length);
        });
  }

  @override
  void dispose() {
    if (recentAddressList.isNotEmpty) {
      Map data = {"address": recentAddressList};
      Constant.session.setData(
          SessionManager.keyRecentAddressSearch, jsonEncode(data), false);
    }
    recentAddressController.close();
    super.dispose();
  }
}
