import 'package:flutter/material.dart';
import 'package:overmaps/helpers/place_attributes.dart';
import 'package:overmaps/helpers/snack_bar.dart';
import 'package:overmaps/models/place.dart';
import 'package:overmaps/services/places_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPlace extends StatefulWidget {
  final String currentPlace;
  final Function selectedPlace;

  const SearchPlace(
      {super.key, required this.currentPlace, required this.selectedPlace});

  @override
  State createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  final PlacesService _service = PlacesService();
  late List placesList = List.empty();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPlace);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inputChanged(widget.currentPlace);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overmaps'),
      ),
      body: Column(
        children: <Widget>[
          placesEditBox(),
          const SizedBox(height: 10.0),
          placesListBox()
        ],
      ),
    );
  }

  void setPlacesListItems(places) {
    setState(() {
      placesList = places;
    });
  }

  void inputChanged(String value) async {
    final places = await _service
        .searchPlaces(
      value,
      AppLocalizations.of(context)!.localeName,
    )
        .catchError((error) {
      SnackMessage.autoHideSnackBar(
          context, AppLocalizations.of(context)!.errorSearchPlaces);
      return Future(() => []);
    });
    setPlacesListItems(places);
  }

  placesEditBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.findPlace,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (text) {
          inputChanged(text);
        },
      ),
    );
  }

  placesListBox() {
    return Expanded(
      child: ListView.builder(
        itemCount: placesList.length,
        itemBuilder: (context, index) {
          var place = placesList.elementAt(index);
          return ListTile(
            title: Text(place[PlaceAttributes.literals.displayName]),
            onTap: () {
              widget.selectedPlace(Place.osm(place));
            },
          );
        },
      ),
    );
  }
}
