import 'package:flutter/material.dart';

import 'package:shimmer_animation/shimmer_animation.dart';

class DetailsScreenShimmerWidget extends StatelessWidget {
  const DetailsScreenShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer(
        child: Column(
          children: [
            Shimmer(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 14),
                child: Shimmer(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: Shimmer(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Shimmer(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                        176, 255, 255, 255),
                                    spreadRadius: 0.01,
                                    blurRadius:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    offset: const Offset(3, 7),
                                  ),
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(107, 33, 149, 243),
                                    spreadRadius: 0.0,
                                    blurRadius:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                    offset: const Offset(1.6, 7),
                                  ),
                                ],
                              ),
                              width: MediaQuery.of(context).size.width * 0.13,
                              height: MediaQuery.of(context).size.width * 0.13,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 14.0),
                            child: Shimmer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.43,
                                      ),
                                      Shimmer(
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.phone_outlined,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const Text("description "),
                                  Shimmer(
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Color.fromARGB(
                                              255, 129, 129, 129),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Shimmer(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: MediaQuery.of(context).size.height * 0.06,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  // color: Colors.blue,
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container();
                  },
                ),
              ),
            ),
            Shimmer(
              child:
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            ),
            Shimmer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Shimmer(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue,
                      ),
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Shimmer(
                        child: Row(
                          children: [
                            Shimmer(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.08,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Shimmer(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.06,
                    ),
                  ),
                  Shimmer(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Shimmer(
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.08,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// /api/v1/categories/childes/6