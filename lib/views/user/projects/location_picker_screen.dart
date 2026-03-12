import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationResult {
  final LatLng latLng;
  final String address;

  LocationResult({required this.latLng, required this.address});
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  const LocationPickerScreen({
    super.key,
    this.initialLocation = const LatLng(13.8476, 100.5696),
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  String _address = "กำลังโหลดข้อมูลสถานที่...";
  bool _isLoading = false;

  Future<void> _getAddress(LatLng latLng) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _address = "กำลังโหลดข้อมูลสถานที่...";
    });

    final apiKey = dotenv.env['GOOGLE_MAP_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _address = "ไม่พบ API KEY ในไฟล์ .env";
        _isLoading = false;
      });
      return;
    }

    final placesUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&rankby=distance&type=establishment&key=$apiKey&language=th';

    final geocodeUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey&language=th';

    try {
      String? placeName;

      final placesResponse = await http.get(Uri.parse(placesUrl));
      if (placesResponse.statusCode == 200) {
        final placesData = json.decode(placesResponse.body);
        if (placesData['status'] == 'OK' && (placesData['results'] as List).isNotEmpty) {
          placeName = placesData['results'][0]['name'];
        }
      }

      final geocodeResponse = await http.get(Uri.parse(geocodeUrl));
      if (geocodeResponse.statusCode == 200) {
        final geocodeData = json.decode(geocodeResponse.body);
        if (geocodeData['status'] == 'OK' && (geocodeData['results'] as List).isNotEmpty) {
          String fullAddress = geocodeData['results'][0]['formatted_address'];
          
          setState(() {
            if (placeName != null) {
              if (fullAddress.contains(placeName)) {
                _address = fullAddress;
              } else {
                _address = "$placeName, $fullAddress";
              }
            } else {
              _address = fullAddress;
            }
          });
        } else {
          setState(() => _address = placeName ?? "ไม่สามารถระบุที่อยู่ได้");
        }
      } else {
        setState(() => _address = placeName ?? "ไม่สามารถดึงที่อยู่จาก Geocode ได้");
      }
    } catch (e) {
      setState(() => _address = "เกิดข้อผิดพลาดในการเชื่อมต่อ: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _getAddress(_pickedLocation!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('เลือกสถานที่'),
        backgroundColor:  Color(0xff3A9AB5),
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon:  Icon(Icons.check_circle, size: 30),
              onPressed: () {
                Navigator.pop(
                  context,
                  LocationResult(latLng: _pickedLocation!, address: _address),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 16,
            ),
            onTap: (latLng) {
              setState(() {
                _pickedLocation = latLng;
              });
              _getAddress(latLng);
            },
            markers: {
              Marker(
                markerId: MarkerId('picked'),
                position: _pickedLocation!,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 8,
              child: Padding(
                padding:  EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text("สถานที่ที่เลือก:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     SizedBox(height: 8),
                    if (_isLoading)  LinearProgressIndicator()
                    else Text(_address, style:  TextStyle(fontSize: 14, color: Colors.black87), maxLines: 3, overflow: TextOverflow.ellipsis),
                     SizedBox(height: 8),
                    Text("พิกัด: ${_pickedLocation!.latitude.toStringAsFixed(6)}, ${_pickedLocation!.longitude.toStringAsFixed(6)}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
