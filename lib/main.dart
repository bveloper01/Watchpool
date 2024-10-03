import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:watchpool/Components/colors.dart';
import 'package:watchpool/Screens/video_view.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Video Platform',
      theme: ThemeData(
        primaryColor: const Color(
            0xFF0D47A1), // Set the primary blue color from your screenshot
        scaffoldBackgroundColor: Colors.white, // Set background to white
        textTheme: const TextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<String> videoIds = [];

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(
      width: 20,
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue[800],
              padding: const EdgeInsets.only(
                top: 35,
                left: 15,
                right: 10,
              ),
              height: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: Image.network(
                        'https://www.promilo.com/assets/logo-default-a2910e84.png'),
                  ),
                  space,
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SizedBox(
                          width: 12,
                        ),
                        FirstNavigation(text: 'Home'),
                        space,
                        FirstNavigation(text: 'Courses'),
                        space,
                        FirstNavigation(text: 'Internships'),
                        space,
                        FirstNavigation(text: 'Jobs'),
                        space,
                        FirstNavigation(text: 'Mentorships')
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: const EdgeInsets.fromLTRB(8, 10, 8, 5),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: Colors.white),
                  const SizedBox(
                    width: 2,
                  ),
                  const Text(
                    "My Stuff",
                    style: TextStyle(color: Colors.white),
                  ),
                  space,
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SizedBox(
                          width: 15,
                        ),
                        SecondNavigation(text: 'My Meeting'),
                        space,
                        SecondNavigation(text: 'My Interest'),
                        space,
                        SecondNavigation(text: 'My Reward'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Funzone',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        cursorColor: primaryColor,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: 'Browse anything for your needs',
                          suffixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryButton(
                    text: 'All',
                    isSelected: true,
                  ),
                  CategoryButton(text: 'Live'),
                  CategoryButton(text: 'News'),
                  CategoryButton(text: 'Sports'),
                  CategoryButton(text: 'Infotainment'),
                  CategoryButton(text: 'Trending'),
                  CategoryButton(text: 'Music'),
                  CategoryButton(text: 'Films & Entertainment'),
                  CategoryButton(text: 'Gaming'),
                  CategoryButton(text: 'Learning'),
                ],
              ),
            ),
            SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.7,
                child: const VideoView()),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String text;
  final bool isSelected;

  const CategoryButton(
      {super.key, required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: isSelected
              ? WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 130, 199, 255))
              : WidgetStateProperty.all<Color>(primaryColor!),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: const BorderSide(color: Colors.transparent)))),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () {},
    );
  }
}

class SecondNavigation extends StatelessWidget {
  final String text;

  const SecondNavigation({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class FirstNavigation extends StatelessWidget {
  final String text;

  const FirstNavigation({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
