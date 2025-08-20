import 'package:flutter/material.dart';

class BlockDelivery extends StatelessWidget {
  BlockDelivery(
      {super.key,
      this.docNum,
      this.onTap,
      this.num,
      this.onCall,
      this.onMap,
      this.from,
      this.fromStreet,
      this.to,
      this.toStreet,
      this.date,
      this.time,
      this.totime,
      this.status});
  dynamic docNum;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onMap;
  final from;
  final fromStreet;
  final to;
  final toStreet;
  final date;
  final time;
  final totime;
  final status;
  dynamic num = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 290,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: const Border(
            top: BorderSide(color: Color.fromARGB(255, 177, 207, 240))),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              top: 85,
              left: 10,
              child: Container(
                height: 32,
                width: 1,
                color: const Color.fromARGB(255, 160, 161, 161),
              )),
          Column(
            children: [
              // Distance & Delivery Code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: status == "On the Way"
                          ? const Color.fromARGB(255, 221, 246, 212)
                          : const Color.fromARGB(255, 246, 243, 212),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: Text(
                      status,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    docNum,
                    style: const TextStyle(
                      fontSize: 13,
                      // color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onMap,
                        child: Container(
                          width:
                              27, // Set width & height equal for perfect circle
                          height: 27,
                          decoration: BoxDecoration(
                            color: Colors.white, // background color (optional)
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromARGB(
                                  255, 175, 176, 178), // border color
                              width: 1, // border width
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.directions,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      GestureDetector(
                        onTap: onCall,
                        child: Container(
                          width:
                              27, // Set width & height equal for perfect circle
                          height: 27,
                          decoration: BoxDecoration(
                            color: Colors.white, // background color (optional)
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromARGB(
                                  255, 175, 176, 178), // border color
                              width: 1, // border width
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.call,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 7),
              const Divider(),

              // Locations
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.store, size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(from,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(fromStreet,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text("$date,",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(time,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("To: $to",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(toStreet,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text("$date,",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(totime,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Spacer(),
              const SizedBox(
                height: 20,
              ),
              // Accept & Reject Buttons
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              //   decoration: BoxDecoration(
              //     color: const Color.fromARGB(255, 235, 206, 119),
              //     borderRadius: BorderRadius.circular(7),
              //   ),
              //   padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
              //   child: const Center(
              //     child: Text(
              //       "Mark as Pick Up",
              //       style: TextStyle(fontSize: 14),
              //     ),
              //   ),
              // ),
              Container(
                margin: const EdgeInsets.fromLTRB(27, 0, 27, 0),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: onTap,
                  // Provider.of<AuthProvider>(context, listen: false)
                  //     .login(_userName.text, _password.text);
                  // Navigator.of(context).pushAndRemoveUntil(
                  //     MaterialPageRoute(
                  //         builder: (_) => WrapperScreen()),
                  //     (route) => false);

                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    backgroundColor: status == "On the Way"
                        ? const Color.fromARGB(255, 78, 178, 24)
                        : const Color.fromARGB(255, 240, 189, 37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    status == "On the Way"
                        ? "Mark as Complete"
                        : "Mark as Pick Up",
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
