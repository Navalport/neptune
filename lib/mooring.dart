import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neptune/types.dart';

class MorringWidget extends StatefulWidget {
  final Berth berth;
  final dynamic docking;

  const MorringWidget({Key? key, required this.berth, required this.docking}) : super(key: key);

  @override
  State<MorringWidget> createState() => _MorringWidgetState();
}

class _MorringWidgetState extends State<MorringWidget> {
  int head = 100;
  String position = "Spring de Proa";
  TimeOfDay _time = const TimeOfDay(hour: 14, minute: 0);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset('assets/static_mooring.png'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Flexible(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Posição",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF292B2F),
                    // itemHeight: 60
                    isDense: false,
                    decoration: const InputDecoration(
                      labelText: "Cabeço",
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                    ),
                    items:
                        [100, 200, 300].map((e) => DropdownMenuItem<int>(value: e, child: Text(e.toString()))).toList(),
                    onChanged: (int? val) {
                      setState(() {
                        head = val ?? 100;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(labelText: "Hora"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                border: Border.all(color: const Color(0xFF36393F)),
                color: const Color(0xFF292B2F),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: SvgPicture.asset(
                            'assets/amarracao.svg',
                            color: const Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: SvgPicture.asset(
                            'assets/mudanca.svg',
                            color: const Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: SvgPicture.asset(
                            'assets/puxada.svg',
                            color: const Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: SvgPicture.asset(
                            'assets/desamarracao.svg',
                            color: const Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: SvgPicture.asset(
                            'assets/ruptura.svg',
                            color: const Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                    border: Border.all(color: const Color(0xFF36393F)),
                    color: const Color(0xFF292B2F),
                  ),
                  child: Scrollbar(
                    radius: const Radius.circular(5),
                    child: ListView.builder(
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      "Spring de Proa",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFF38D36),
                                      ),
                                    ),
                                    Text(
                                      "308",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFF38D36),
                                      ),
                                    ),
                                    Text(
                                      "14:00 10/nov",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFF38D36),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      "Spring de Proa",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF15858A),
                                      ),
                                    ),
                                    Text(
                                      "308",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF15858A),
                                      ),
                                    ),
                                    Text(
                                      "14:00 10/nov",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF15858A),
                                      ),
                                    ),
                                  ],
                                ),
                              ][index],
                            ),
                          );
                        }),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
