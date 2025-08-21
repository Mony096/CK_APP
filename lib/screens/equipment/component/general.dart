import 'package:bizd_tech_service/component/text_field.dart';
import 'package:bizd_tech_service/component/text_remark.dart';
import 'package:bizd_tech_service/component/title_break.dart';
import 'package:flutter/material.dart';

class General extends StatefulWidget {
  const General({super.key, this.controller});

  // Specify the type here
  final Map<String, dynamic>? controller;

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          color: Colors.white,
          // borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 7),
              const ComponentTitle(
                label: "Infomation",
              ),
              const SizedBox(height: 8),
              // const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['equipCode'],
                label: 'Equipment Code',
                star: true,
                // icon: const Icon(Icons.qr_code_scanner,
                //     color: Colors.grey),
                // onclickIcon: () {
                //   print("Scan icon tapped!");
                // },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Equipment Name',
                star: true,
                // icon: const Icon(Icons.qr_code_scanner,
                //     color: Colors.grey),
                // onclickIcon: () {
                //   print("Scan icon tapped!");
                // },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Customer',
                star: true,
                icon: const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Status',
                star: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Site',
                star: false,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Brand',
                star: true,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Serial Number',
                star: true,
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.grey,
                  size: 25,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 8),
              CustomTextRemark(
                controller: widget.controller?['equipName'],
                label: 'Remark',
              ),
              const SizedBox(height: 28),
              const ComponentTitle(
                label: "Date & images",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Upload Image',
                star: true,
                icon: const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Installed Date',
                star: true,
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Next Service Date',
                star: false,
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Warranty Expire Date',
                star: true,
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
