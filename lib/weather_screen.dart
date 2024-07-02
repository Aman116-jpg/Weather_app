import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';

import 'package:intl/intl.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

import 'secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {



  Future<Map<String,dynamic>> getCurrentWeather() async {
     // Debug statement
    try {

      String cityName = 'Delhi';
      final res = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$cityName,india&APPID=$openWeatherAPIKey',
        ),
      );



      final data = jsonDecode(res.body);



      if (data == null || data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      return data;
    } catch (e) {
      // Debug statement
      throw e.toString();
    }
  }



    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather app',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {

              });
            },
          ),
        ],
      ),
      body:
      FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }


          if(snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTempK = currentWeatherData['main']['temp'];
          final currentTempC = currentTempK - 273.15;

          final currentSky = currentWeatherData['weather'][0]['main'];

          final currentPressure = currentWeatherData['main']['pressure'];

          final currentWindSpeed = currentWeatherData['wind']['speed'] * 3.6;

          final currentHumidity = currentWeatherData['main']['humidity'];







          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '${currentTempC.toStringAsFixed(1)} °C',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud: Icons.sunny,

                              size: 65,
                            ),
                             const SizedBox(height: 10),
                              Text(
                              currentSky,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hourly Forecast',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              //   SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //
              //     children: [
              //       for(int i = 0; i<33; i++)
              //         HourlyForecastItem(
              //           time:  data['list'][i+1]['dt'].toString(),
              //           temperature: data['list'][i+1]['main']['temp'].toString(),
              //           icon: data['list'][i+1]['weather'][0]['main'] == 'Clouds' ||  data['list'][i+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud: Icons.sunny,
              //         ),
              //
              //
              //     ],
              //   ),
              // ),
              
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                    itemBuilder: (context,index){
                    final hourlyForecast = data['list'][index+1];
                    final hourlySky = data['list'][index+1]['weather'][0]['main'];
                    final hourlyTempK = hourlyForecast['main']['temp'];
                    final hourlyTempC = hourlyTempK - 273.15;

                    final time = DateTime.parse(hourlyForecast['dt_txt']);

                    return HourlyForecastItem(
                        time:DateFormat.j().format(time),
                        temperature: '${hourlyTempC.toStringAsFixed(1)} °C',
                        icon:hourlySky == 'Clouds' ||  hourlySky == 'Rain' ? Icons.cloud: Icons.sunny,
                    );

                    },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '$currentHumidity %',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind speed',
                    value: '${currentWindSpeed.toStringAsFixed(1)} km/h',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value:  '$currentPressure mbar',
                  ),
                ],
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}
